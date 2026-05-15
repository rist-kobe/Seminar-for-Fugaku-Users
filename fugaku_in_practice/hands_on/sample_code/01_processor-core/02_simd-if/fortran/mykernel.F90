! Copyright 2024 Research Organization for Information Science and Technology
module mykernel
  implicit none
  integer, parameter :: MAXINUM = 2000
  real(8) :: xt, yt, zt

  integer, allocatable, dimension(:) :: il
  real(8), allocatable, dimension(:) :: x
  real(8), allocatable, dimension(:) :: y
  real(8), allocatable, dimension(:) :: z

contains
  subroutine calc1 (inum, rcut2, g, f) 
    integer, intent(in) :: inum
    real(8), intent(in) :: rcut2
    real(8), intent(out) :: g(1:inum)
    real(8), intent(inout) :: f

    integer :: i, ii 
    real(8) :: dx, dy, dz, r2, u

    f = 0.0D0 

    call setup()

    do i = 1, inum
       ii = il(i) 
       dx = xt - x(ii)
       dy = yt - y(ii)
       dz = zt - z(ii)
       r2 = dx*dx + dy*dy + dz*dz
       if ( r2 .lt. rcut2 ) then
          u = exp(-0.5D0*r2/rcut2) 
          g(ii) = x(ii) + y(ii) + z(ii) + u
       end if
    end do
  end subroutine calc1

  subroutine calc2 (inum, rcut2, g, f) 
    integer, intent(in) :: inum
    real(8), intent(in) :: rcut2
    real(8), intent(out) :: g(1:inum)
    real(8), intent(inout) :: f

    integer :: i, ii
    real(8) :: dx, dy, dz, r2, u
    
    call setup()

    f = 0.0D0 

    do i = 1, inum
       ii = il(i) 
       dx = xt - x(ii)
       dy = yt - y(ii)
       dz = zt - z(ii)
       r2 = dx*dx + dy*dy + dz*dz
       if ( r2 .lt. rcut2 ) then
          u = exp(-0.5D0*r2/rcut2) 
          g(ii) = x(ii) + y(ii) + z(ii) + u 
          f = f + u*dx + u*dy + u*dz
       end if
    end do
  end subroutine calc2

  subroutine calc2_mod (inum, rcut2, g, f) 
    integer, intent(in) :: inum
    real(8), intent(in) :: rcut2
    real(8), intent(out) :: g(1:inum)
    real(8), intent(inout) :: f

    integer :: i, ii, ei
    integer :: il_(MAXINUM)
    real(8) :: dx, dy, dz, r2, u
    real(8) :: dx_(MAXINUM), dy_(MAXINUM), dz_(MAXINUM), r2_(MAXINUM)

    call setup()

    ei = 1
    do i =1, inum
       ii = il(i) 
       dx = xt - x(ii)
       dy = yt - y(ii)
       dz = zt - z(ii)
       r2 = dx*dx + dy*dy + dz*dz
       if ( r2 .lt. rcut2 ) then
          il_(ei) = ii
          dx_(ei) = dx
          dy_(ei) = dy
          dz_(ei) = dz
          r2_(ei) = r2
          ei = ei + 1
       end if
    end do

    ei = ei - 1

    f = 0.0D0 

    if ( ei .lt. 8 ) then

!OCL NOSIMD
       do i = 1, ei
          ii = il_(i) 
          dx = dx_(i)
          dy = dy_(i)
          dz = dz_(i)
          r2 = r2_(i)
          u = exp(-0.5D0*r2/rcut2) 
          g(ii) = x(ii) + y(ii) + z(ii) + u
          f = f + u*dx + u*dy + u*dz
       end do

    else

       do i = 1, ei
          ii = il_(i) 
          dx = dx_(i)
          dy = dy_(i)
          dz = dz_(i)
          r2 = r2_(i)
          u = exp(-0.5D0*r2/rcut2) 
          g(ii) = x(ii) + y(ii) + z(ii) + u
          f = f + u*dx + u*dy + u*dz
       end do

    end if
  end subroutine calc2_mod

  subroutine count_true (inum, rcut2, t_rate) 
    integer, intent(in) :: inum
    real(8), intent(in) :: rcut2
    real(8), intent(out) :: t_rate

    integer :: i, ii, ei
    real(8) :: dx, dy, dz, r2

    call setup()

    ei = 1
    do i =1, inum
       ii = il(i) 
       dx = xt - x(ii)
       dy = yt - y(ii)
       dz = zt - z(ii)
       r2 = dx*dx + dy*dy + dz*dz
       if ( r2 .lt. rcut2 ) then
          ei = ei + 1
       end if
    end do

    ei = ei - 1

    t_rate = dble(ei) / inum

  end subroutine count_true

  subroutine setup ()
    xt = 0.0
    yt = 0.0
    zt = 0.0
  end subroutine setup
end module mykernel
