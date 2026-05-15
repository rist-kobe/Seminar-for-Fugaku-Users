! Copyright 2024 Research Organization for Information Science and Technology
!--------------------------------------------------------------------
! Utility functions
!--------------------------------------------------------------------
module util_mpi
      
contains
   subroutine source_term_mpi (nxsta, nxend, nysta, nyend, dx, dy, it, s)
      implicit none
      integer,intent(in) :: nxsta, nxend
      integer,intent(in) :: nysta, nyend
      real(8),intent(in) :: dx
      real(8),intent(in) :: dy
      integer,intent(in) :: it
      real(8),intent(out) :: s(nxsta:nxend,nysta:nyend)
   
      integer :: ix, iy
   
      real(8),parameter :: c0 = 1.0D0;
      real(8),parameter :: c1 = 0.0D0;
      real(8),parameter :: c2 = -0.5D0;
      real(8),parameter :: c3 = 0.0D0;
      real(8),parameter :: c4 = 0.042D0;
      real(8) :: x, y, u, v
   
      do iy = nysta, nyend
         y = iy*dy
         v = (((c4*y + c3)*y + c2)*y + c1)*y + c0;
      do ix = nxsta, nxend
         x = ix*dx
         u = (((c4*x + c3)*x + c2)*x + c1)*x + c0;
         s(ix, iy) = u*v*cos(it*1.0D-6)
      end do
      end do
   end subroutine 
   
   subroutine forward_dx_mpi (nxend1, nxsta, nxend, nysta, nyend, &
   &   nysize_local, fend, f, fd)
      implicit none
      integer,intent(in) :: nxend1
      integer,intent(in) :: nxsta, nxend
      integer,intent(in) :: nysta, nyend
      integer,intent(in) :: nysize_local
      real(8),intent(in) :: fend(1:nysize_local)
      real(8),intent(in) :: f(nxsta:nxend,nysta:nyend)
      real(8),intent(out) :: fd(nxsta:nxend,nysta:nyend)
   
      integer :: ix, iy, ii
   
      do iy = nysta, nyend
      do ix = nxsta, nxend1
         fd(ix,iy) = f(ix+1,iy) - f(ix,iy)
      end do
      end do
   
      ix = nxend
      do iy = nysta, nyend
         ii = iy - nysta + 1
         fd(ix, iy) = fend(ii) - f(ix,iy)
      end do
   end subroutine
   
   subroutine forward_dy_mpi (nyend1, nxsta, nxend, nysta, nyend, &
   &   nxsize_local, fend, f, fd)
      implicit none
      integer,intent(in) :: nyend1
      integer,intent(in) :: nxsta, nxend
      integer,intent(in) :: nysta, nyend
      integer,intent(in) :: nxsize_local
      real(8),intent(in) :: fend(1:nxsize_local)
      real(8),intent(in) :: f(nxsta:nxend,nysta:nyend)
      real(8),intent(out) :: fd(nxsta:nxend,nysta:nyend)
   
      integer :: ix, iy, ii
   
      do iy = nysta, nyend1
      do ix = nxsta, nxend
         fd(ix,iy) = f(ix,iy+1) - f(ix,iy)
      end do
      end do
   
      iy = nyend
      do ix = nxsta, nxend
         ii = ix - nxsta + 1
         fd(ix,iy) = fend(ii) - f(ix,iy)
      end do
   end subroutine
   
   subroutine bc_x_mpi (nxsta, nxend, nysta, nyend, fd)
      implicit none
      integer,intent(in) :: nxsta, nxend
      integer,intent(in) :: nysta, nyend
      real(8),intent(out) :: fd(nxsta:nxend,nysta:nyend)
   
      integer :: ix, iy
   
      ix = nxend
      do iy = nysta, nyend
         fd(ix,iy) = 0.0D0
      end do
   end subroutine
   
   subroutine bc_y_mpi (nxsta, nxend, nysta, nyend, fd)
      implicit none
      integer,intent(in) :: nxsta, nxend
      integer,intent(in) :: nysta, nyend
      real(8),intent(out) :: fd(nxsta:nxend,nysta:nyend)
   
      integer :: ix, iy
   
      iy = nyend
      do ix = nxsta, nxend
         fd(ix,iy) = 0.0D0
      end do
   end subroutine
end module 
