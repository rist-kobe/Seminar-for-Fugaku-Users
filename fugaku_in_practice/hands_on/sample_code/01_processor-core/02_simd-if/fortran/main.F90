! Copyright 2024 Research Organization for Information Science and Technology
program main
  use, intrinsic::iso_c_binding
  use mykernel, only: MAXINUM, il, x, y, z, &
  &                   calc1, calc2, calc2_mod, count_true
  implicit none

  integer, parameter :: STRIDE_DP=4
  integer, parameter :: NITR=100000
  integer :: inum, itrue_rate, narg
  integer :: i, ii, it
  character(len=128) :: cbuff

  real(8),parameter :: SCALEFAC=1.0D-1
  real(8),allocatable,dimension(:) :: g
  real(8) :: f
  real(8) :: rcut2
  real(8) :: tmp, t_rate
  real(8) :: elp0, elp(3)

  interface
  real(kind=c_double) function get_elp_time() bind(c)
  use, intrinsic::iso_c_binding, only: c_double
  end function get_elp_time
  end interface

  narg = command_argument_count() 
  if ( narg .ne. 2 ) then
     write(6,'(1A)') "[usage] run.x (arg1) (arg2) "
     write(6,'(1A)') "  (arg1): array size (integer)"
     write(6,'(1A)') "  (arg2): true rate (integer)"
     write(6,'(1A)') "     -1 means default (arg2=10)."
     write(6,'(1A)') "     0 means no true."
     write(6,'(1A)') "     Larger means more true."
     stop
  end if

  call get_command_argument(1, cbuff)
  read(cbuff, '(1I10)') inum
  if ( inum <= 0 ) then
     inum = 200
  end if

  call get_command_argument(2, cbuff)
  read(cbuff, '(1I10)') itrue_rate
  if ( itrue_rate .lt. 0 ) then
     itrue_rate = 10
  end if
  rcut2 = 0.5D-1 * dble(itrue_rate) * dble(inum) * SCALEFAC
  rcut2 = rcut2 * rcut2

  if ( inum .gt. MAXINUM ) then
     write(6,'(1A, 1I10)') "Error: inum must be smaller than ", MAXINUM
     stop 
  end if

  ! Data preparation
  allocate ( il(1:inum) )
  allocate ( x(1:inum) )
  allocate ( y(1:inum) )
  allocate ( z(1:inum) )
  allocate ( g(1:inum) )

  do i = 1, inum
     tmp = 0.5D0*inum - i + 1
     tmp = tmp * SCALEFAC
     x(i) = tmp  
     y(i) = tmp + SCALEFAC
     z(i) = tmp + 2.0D0*SCALEFAC
  end do
  !! for debug
  !do i= 1, inum
  !  write(99,'(3F17.8)') x(i), y(i), z(i) 
  !end do

  ! Note: There is no overlap b/w the elements
  do i = 1, inum
    ii = i + STRIDE_DP
    if ( ii > inum ) then
       ii = ii - inum
    end if 
    il(i) = ii
  end do
  !! for debug
  !do i= 1, inum
  !  write(99,'(2I10)') i , il(i)
  !end do

  ! Calculate true rate
  call count_true (inum, rcut2, t_rate)

  ! Kernel 1
  g(:) = 0.0D0

  f = 0.0D0

  elp0 = get_elp_time()
  do it = 1, NITR
     call calc1(inum, rcut2, g, f)
     g(1) = it*1.0D-9 ! fake
     f = it*1.0D-9 ! fake
  end do
  elp(1) = get_elp_time() - elp0

  ! Kernel 2
  g(:) = 0.0D0

  f = 0.0D0

  elp0 = get_elp_time()
  do it = 1, NITR
     call calc2(inum, rcut2, g, f)
     g(1) = it*1.0D-9 ! fake
     f = it*1.0D-9 ! fake
  end do
  elp(2) = get_elp_time() - elp0

  ! Kernel 2 modified (manually creating list array)
  g(:) = 0.0D0

  f = 0.0D0

  elp0 = get_elp_time()
  do it = 1, NITR
     call calc2_mod(inum, rcut2, g, f)
     g(1) = it*1.0D-9 ! fake
     f = it*1.0D-9 ! fake
  end do
  elp(3) = get_elp_time() - elp0

  write(6, '("Array size: ",1I10)') inum 
  write(6, '("True rate : ",1F11.2)') t_rate 
  write(6, '("Elapsed time (sec.)")') 
  write(6, '("  Kernel 1    :", 1F12.3)') elp(1)
  write(6, '("  Kernel 2    :", 1F12.3)') elp(2)
  write(6, '("  Kernel 2 mod:", 1F12.3)') elp(3)
  write(6, '("Dummy output:", 2F16.5)') g(1), f 

  stop
end program main
