! Copyright 2024 Research Organization for Information Science and Technology
program main
   use, intrinsic::ISO_C_BINDING
   use util
   implicit none

   integer, parameter :: NITR = 10000
   integer :: narg
   integer :: nxsize, nysize
   integer :: ix, iy, it
   character(len=128) :: cbuff
  
   real(8), allocatable, dimension(:,:) :: f
   real(8), allocatable, dimension(:,:) :: fdx
   real(8), allocatable, dimension(:,:) :: fdy
   real(8), allocatable, dimension(:,:) :: s
   real(8) :: v
   real(8) :: dx, dy
   real(8) :: elp0, elp

   interface
   real(kind=c_double) function get_elp_time () bind(c)
      use, intrinsic::ISO_C_BINDING, only: c_double
   end function
   end interface

   narg = command_argument_count()
   if ( narg .eq. 2 ) then
      call get_command_argument(1, cbuff)
      read(cbuff, '(1I10)') nxsize
      call get_command_argument(2, cbuff)
      read(cbuff, '(1I10)') nysize
   else
      nxsize = 100
      nysize = 100
   end if
!--------------------------------------------------------------------
! Initialization
!--------------------------------------------------------------------
   dx = 1.0D0 / (nxsize - 1 )
   dy = 1.0D0 / (nysize - 1 )

   allocate ( f(1:nxsize,1:nysize)   )
   allocate ( fdx(1:nxsize,1:nysize) )
   allocate ( fdy(1:nxsize,1:nysize) )
   allocate ( s(1:nxsize,1:nysize)   )

   do iy = 1, nysize
   do ix = 1, nxsize
      f(ix,iy) = 0.0D0
   end do
   end do

   call forward_dx (nxsize, nysize, f, fdx)
   call forward_dy (nxsize, nysize, f, fdy)

   call bc_x (nxsize, nysize, fdx)
   call bc_y (nxsize, nysize, fdy)

   call source_term (nxsize, nysize, dx, dy, 0, s)
!--------------------------------------------------------------------
! Main loop
!--------------------------------------------------------------------
   elp0 = get_elp_time()
 
   loopit: do it = 1, NITR
      do iy = 1, nysize
      do ix = 1, nxsize
         f(ix,iy) = s(ix,iy) + 0.25D0*fdx(ix,iy) + 0.25D0*fdy(ix,iy)
      end do
      end do

      call forward_dx (nxsize, nysize, f, fdx)
      call forward_dy (nxsize, nysize, f, fdy)

      call bc_x (nxsize, nysize, fdx)
      call bc_y (nxsize, nysize, fdy)

      call source_term (nxsize, nysize, dx, dy, it, s)
   end do loopit

   elp = get_elp_time() - elp0
!--------------------------------------------------------------------
! Finalization
!--------------------------------------------------------------------
   v = 0.0D0
   do iy = 1, nysize
   do ix = 1, nxsize
      v = v + f(ix, iy)*f(ix, iy)*dx*dy
   end do
   end do

   write (6, '("Elapsed time of main loop (s):",1F11.4)') elp
   write (6, '("Dummy output :",1E19.8)') v

   stop
end program main
