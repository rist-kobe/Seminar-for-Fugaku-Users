! Copyright 2024 Research Organization for Information Science and Technology
program main
   use, intrinsic::ISO_C_BINDING
   use util_mpi
   implicit none

   include 'mpif.h'

   integer, parameter :: NITR = 10000
   integer :: narg
   integer :: nxsize, nysize
   integer :: ix, iy, it, ii
   character(len=128) :: cbuff

   integer :: np, npx, npy, me, provided, ierr
   integer :: cartComm
   integer :: ndims
   integer :: dims(1:2), coords(1:2)
   integer :: disp_x, disp_y
   integer :: rank_src_x, rank_dest_x, rank_src_y, rank_dest_y
   integer :: q, r
   integer :: nxsize_local, nxsta, nxend, nxend1
   integer :: nysize_local, nysta, nyend, nyend1
   integer :: max_buffer_size
   integer :: tag
   integer :: stat(MPI_STATUS_SIZE) 
   logical :: reorder, periods(1:2)

   real(8), allocatable, dimension(:,:) :: f
   real(8), allocatable, dimension(:,:) :: fdx
   real(8), allocatable, dimension(:,:) :: fdy
   real(8), allocatable, dimension(:,:) :: s
   real(8) :: v
   real(8) :: dx, dy
   real(8) :: elp0, elp

   real(8), allocatable, dimension(:) :: send_buff
   real(8), allocatable, dimension(:) :: recv_buff
   real(8) :: vtot

   interface
   real(kind=c_double) function get_elp_time () bind(c)
      use, intrinsic::ISO_C_BINDING, only: c_double
   end function
   end interface

   narg = command_argument_count()
   if ( narg .eq. 4 ) then
      call get_command_argument(1, cbuff)
      read(cbuff, '(1I10)') nxsize
      call get_command_argument(2, cbuff)
      read(cbuff, '(1I10)') nysize
      call get_command_argument(3, cbuff)
      read(cbuff, '(1I10)') npx
      call get_command_argument(4, cbuff)
      read(cbuff, '(1I10)') npy
   else
      nxsize = 10
      nysize = 1000
      npx = 1
   end if
!--------------------------------------------------------------------
! MPI setting
!--------------------------------------------------------------------
   call MPI_INIT_THREAD (MPI_THREAD_SINGLE, provided, ierr)
   call MPI_COMM_SIZE (MPI_COMM_WORLD, np, ierr)
   call MPI_COMM_RANK (MPI_COMM_WORLD, me, ierr)
   if ( MPI_THREAD_SINGLE < provided ) then
      if ( me .eq. 0 ) then
         write (6, '("Error: Please check thread level in your MPI.")')
         write (6, '("Required: ",1I3)') MPI_THREAD_SINGLE
         write (6, '("Provided: ",1I3)') provided
      end if
      call MPI_FINALIZE (ierr)
      stop
   end if
   if ( npx .eq. 1 ) then
      npy = np;
   end if
   if ( np .ne. npx*npy ) then
      if ( me.eq. 0 ) then
         write (6, '("Error: npx * npy must be equal to the number of MPI proc.")')
         write (6, '("Your npx (=3rd arg): ",1I5)') npx
         write (6, '("Your npy (=4th arg): ",1I5)') npy
      end if
      call MPI_FINALIZE (ierr)
      stop
   end if

   ! 2D Cartesian topology
   ndims = 2
   reorder = .FALSE.
   periods(1) = .FALSE.
   periods(2) = .FALSE.
   dims(1) = npx
   dims(2) = npy

   call MPI_CART_CREATE (MPI_COMM_WORLD, ndims, dims, periods, &
   &   reorder, cartComm, ierr)
   call MPI_CART_COORDS (cartComm, me, 2, coords, ierr)

   disp_x = -1 ! downwards
   disp_y = -1 ! downwards
   call MPI_CART_SHIFT (cartComm, 0, disp_x, rank_src_x, rank_dest_x, ierr)
   call MPI_CART_SHIFT (cartComm, 1, disp_y, rank_src_y, rank_dest_y, ierr)

  ! Decomposition 
  q = nxsize / dims(1)
  r = mod(nxsize,dims(1))
  if ( coords(1) < r ) then
     nxsize_local = q + 1
     nxsta = 1 + coords(1)*nxsize_local
  else 
     nxsize_local = q
     nxsta = 1 + coords(1)*nxsize_local + r
  end if
  nxend  = nxsta + nxsize_local - 1 
  nxend1 = nxend - 1

  q = nysize / dims(2)
  r = mod(nysize,dims(2))
  if ( coords(2) < r ) then
     nysize_local = q + 1
     nysta = 1 + coords(2)*nysize_local
  else 
     nysize_local = q
     nysta = 1 + coords(2)*nysize_local + r
  end if
  nyend  = nysta + nysize_local - 1 
  nyend1 = nyend - 1

  q = (nxsize/npx) + 1
  r = (nysize/npy) + 1
  max_buffer_size = max(q, r)

  ! For p2p communication
  tag = 999
  allocate ( send_buff(1:max_buffer_size) )
  allocate ( recv_buff(1:max_buffer_size) )
  send_buff(:) = 0.0
  recv_buff(:) = 0.0
#if 0
   ! for debug
   BLOCK
   integer, parameter :: debug_w_unit = 91
   character(len=128) :: fname
   fname = "chk.0000"
   write (fname(5:8), '(1I0.4)') me

   open (debug_w_unit, file=fname)
   write (debug_w_unit, '("rank       =",1I5)') me
   write (debug_w_unit, '("cart coord =",1I5,",",1I5)') coords(1), coords(2)
   write (debug_w_unit, '("rank_src_x =",1I5)') rank_src_x
   write (debug_w_unit, '("rank_dest_x=",1I5)') rank_dest_x
   write (debug_w_unit, '("rank_src_y =",1I5)') rank_src_y
   write (debug_w_unit, '("rank_dest_y=",1I5)') rank_dest_y
   write (debug_w_unit, '("nxsta      =",1I5)') nxsta
   write (debug_w_unit, '("nxend      =",1I5)') nxend
   write (debug_w_unit, '("nysta      =",1I5)') nysta
   write (debug_w_unit, '("nyend      =",1I5)') nyend
   write (debug_w_unit, '("max_buffer_size =",1I5)') max_buffer_size
   close(debug_w_unit)
   END BLOCK
#endif
!--------------------------------------------------------------------
! Initialization
!--------------------------------------------------------------------
   dx = 1.0D0 / (nxsize - 1 )
   dy = 1.0D0 / (nysize - 1 )

   allocate ( f(nxsta:nxend,nysta:nyend) )
   allocate ( fdx(nxsta:nxend,nysta:nyend) )
   allocate ( fdy(nxsta:nxend,nysta:nyend) )
   allocate ( s(nxsta:nxend,nysta:nyend) )

   do iy = nysta, nyend
   do ix = nxsta, nxend
      f(ix,iy) = 0.0D0
   end do
   end do

   ! p2p communication along x-direction  
   ix = nxsta
   do iy = nysta, nyend
      ii = iy - nysta + 1
      send_buff(ii) = f(ix, iy)
   end do
   call MPI_SENDRECV (                                        &
  &   send_buff, nysize_local, MPI_DOUBLE, rank_dest_x, tag,  &
  &   recv_buff, nysize_local, MPI_DOUBLE, rank_src_x,  tag,  &
  &   cartComm, stat, ierr)
   call forward_dx_mpi (nxend1, nxsta, nxend, nysta, nyend,   &
  &   nysize_local, recv_buff, f, fdx)

   ! p2p communication along y-direction  
   iy = nysta
   do ix = nxsta, nxend
      ii = ix - nxsta + 1
      send_buff(ii) = f(ix, iy)
   end do
   call MPI_SENDRECV (                                       &
  &   send_buff, nxsize_local, MPI_DOUBLE, rank_dest_y, tag, &
  &   recv_buff, nxsize_local, MPI_DOUBLE, rank_src_y,  tag, &
  &   cartComm, stat, ierr)
   call forward_dy_mpi (nyend1, nxsta, nxend, nysta, nyend,  &
  &   nxsize_local, recv_buff, f, fdy)

   if ( coords(1) .eq. npx - 1 ) then
      call bc_x_mpi (nxsta, nxend, nysta, nyend, fdx)
   end if
   if ( coords(2) .eq. npy - 1 ) then
      call bc_y_mpi (nxsta, nxend, nysta, nyend, fdy)
   end if

   call source_term_mpi (nxsta, nxend, nysta, nyend, dx, dy, 0, s)
!--------------------------------------------------------------------
! Main loop
!--------------------------------------------------------------------
   call MPI_BARRIER(MPI_COMM_WORLD, ierr)
   elp0 = get_elp_time()
 
   loopit: do it = 1, NITR
      do iy = nysta, nyend
      do ix = nxsta, nxend
         f(ix,iy) = s(ix,iy) + 0.25D0*fdx(ix,iy) + 0.25D0*fdy(ix,iy)
      end do
      end do

      ! p2p communication along x-direction  
      do iy = nysta, nyend
         ii = iy - nysta + 1
         send_buff(ii) = f(nxsta, iy)
      end do
      call MPI_SENDRECV (                                       &
     &   send_buff, nysize_local, MPI_DOUBLE, rank_dest_x, tag, &
     &   recv_buff, nysize_local, MPI_DOUBLE, rank_src_x,  tag, &
     &   cartComm, stat, ierr)
      call forward_dx_mpi (nxend1, nxsta, nxend, nysta, nyend,  &
     &   nysize_local, recv_buff, f, fdx)

      ! p2p communication along y-direction  
      do ix = nxsta, nxend
         ii = ix - nxsta + 1
         send_buff(ii) = f(ix, nysta)
      end do
      call MPI_SENDRECV (                                        &
     &    send_buff, nxsize_local, MPI_DOUBLE, rank_dest_y, tag, &
     &    recv_buff, nxsize_local, MPI_DOUBLE, rank_src_y,  tag, &
     &    cartComm, stat, ierr)
      call forward_dy_mpi (nyend1, nxsta, nxend, nysta, nyend,  &
     &   nxsize_local, recv_buff, f, fdy)

      if ( coords(1) .eq. npx - 1 ) then
         call bc_x_mpi (nxsta, nxend, nysta, nyend, fdx)
      end if
      if ( coords(2) .eq. npy - 1 ) then
         call bc_y_mpi (nxsta, nxend, nysta, nyend, fdy)
      end if

      call source_term_mpi (nxsta, nxend, nysta, nyend, dx, dy, it, s)
   end do loopit

   call MPI_BARRIER(MPI_COMM_WORLD, ierr)
   elp = get_elp_time() - elp0
!--------------------------------------------------------------------
! Finalization
!--------------------------------------------------------------------
   v = 0.0D0
   do iy = nysta, nyend
   do ix = nxsta, nxend
      v = v + f(ix, iy)*f(ix, iy)*dx*dy
   end do
   end do

   vtot = 0.0D0
   call MPI_REDUCE(v, vtot, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD, ierr)

   if ( me == 0 ) then
      write (6, '("Elapsed time of main loop (s):",1F11.4)') elp
      write (6, '("Dummy output :",1E19.8)') vtot
   end if

   call MPI_FINALIZE (ierr)
   stop
end program main
