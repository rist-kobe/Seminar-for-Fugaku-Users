! Copyright 2024 Research Organization for Information Science and Technology
!--------------------------------------------------------------------
! Utility functions
!--------------------------------------------------------------------
module util
   
contains
   subroutine source_term (nxsize, nysize, dx, dy, it, s)
      implicit none
      integer,intent(in) :: nxsize
      integer,intent(in) :: nysize
      real(8),intent(in) :: dx
      real(8),intent(in) :: dy
      integer,intent(in) :: it
      real(8),intent(out) :: s(nxsize,nysize)
   
      integer :: ix, iy
   
      real(8),parameter :: c0 = 1.0D0;
      real(8),parameter :: c1 = 0.0D0;
      real(8),parameter :: c2 = -0.5D0;
      real(8),parameter :: c3 = 0.0D0;
      real(8),parameter :: c4 = 0.042D0;
      real(8) :: x, y, u, v
   
      do iy = 1, nysize
         y = iy*dy
         v = (((c4*y + c3)*y + c2)*y + c1)*y + c0;
      do ix = 1, nxsize
         x = ix*dx
         u = (((c4*x + c3)*x + c2)*x + c1)*x + c0;
         s(ix, iy) = u*v*cos(it*1.0D-6)
      end do
      end do
   end subroutine 
   
   subroutine forward_dx (nxsize, nysize, f, fd)
      implicit none
      integer,intent(in) :: nxsize
      integer,intent(in) :: nysize
      real(8),intent(in) :: f(nxsize,nysize)
      real(8),intent(out) :: fd(nxsize,nysize)
   
      integer :: ix, iy
   
      do iy = 1, nysize
      do ix = 1, nxsize-1
         fd(ix,iy) = f(ix+1,iy) - f(ix,iy)
      end do
      end do
   end subroutine
   
   subroutine forward_dy (nxsize, nysize, f, fd)
      implicit none
      integer,intent(in) :: nxsize
      integer,intent(in) :: nysize
      real(8),intent(in) :: f(nxsize,nysize)
      real(8),intent(out) :: fd(nxsize,nysize)
   
      integer :: ix, iy
   
      do iy = 1, nysize-1
      do ix = 1, nxsize
         fd(ix,iy) = f(ix,iy+1) - f(ix,iy)
      end do
      end do
   end subroutine
   
   subroutine bc_x (nxsize, nysize, fd)
      implicit none
      integer,intent(in) :: nxsize
      integer,intent(in) :: nysize
      real(8),intent(out) :: fd(nxsize,nysize)
   
      integer :: ix, iy
   
      ix = nxsize
      do iy = 1, nysize
         fd(ix,iy) = 0.0D0
      end do
   end subroutine
   
   subroutine bc_y (nxsize, nysize, fd)
      implicit none
      integer,intent(in) :: nxsize
      integer,intent(in) :: nysize
      real(8),intent(out) :: fd(nxsize,nysize)
   
      integer :: ix, iy
   
      iy = nysize
      do ix = 1, nxsize
         fd(ix,iy) = 0.0D0
      end do
   end subroutine
end module util
