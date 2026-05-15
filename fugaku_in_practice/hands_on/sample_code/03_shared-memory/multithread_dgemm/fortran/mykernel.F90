! Copyright 2024 Research Organization for Information Science and Technology
module mykernel
   use mytype, only: DP
   real(kind=DP),parameter :: zero = 0.0_DP, one = 1.0_DP
   
   contains
   
   subroutine initialize (MC, MA, MB, ns)
     implicit none
     integer,intent(in) :: ns 
     real(kind=DP),intent(out) :: MC(ns,ns), MA(ns,ns), MB(ns,ns)
   
     integer :: i, j, nseed
     integer,allocatable,dimension(:) :: seed
     real(kind=DP) :: rnd(2)
     real(kind=DP) :: tmp
   
     call random_seed(size=nseed)
   
     allocate ( seed(1:nseed) )
   
     do i = 1, nseed
        !call system_clock(count=seed(i))
        seed(i) = 20409102 + i - 1
     end do
     call random_seed(put=seed)
   
     tmp = one / ns
     do j = 1, ns
     do i = 1, ns
        call random_number(rnd)
        MA(i,j) = rnd(1) * tmp 
        MB(i,j) = rnd(2) * tmp
        MC(i,j) = zero
     end do
     end do
   
     deallocate( seed )
   end subroutine initialize
   
 !=========================================================================
 !  Simple implementation
 !  * Memory access pattern 
 !        stride  : non-contiguous access with stride > 1
 !        cont    : contiguous access (stride 1 access)
 !        register: on register 
 ! ====================================================
 ! loop depth |     MC         MA         MB
 !  j         | stride      register    stride 
 !  k         | register    stride      cont  
 !  i         | cont        cont        register 
 !=========================================================================
   subroutine mmp_simple (MC, MA, MB, ns)
     implicit none
     integer,intent(in) :: ns 
     real(kind=DP),intent(in) :: MA(ns,ns), MB(ns,ns)
     real(kind=DP),intent(out) :: MC(ns,ns)
   
     integer :: i, j, k
   
     MC(:,:) = 0.0_DP
   
     do j = 1, ns
     do k = 1, ns
     do i = 1, ns
           MC(i,j) = MC(i,j) + MA(i,k)*MB(k,j) 
     end do
     end do
     end do
   end subroutine mmp_simple
   
!=========================================================================
!  Simple loop blocking
!  * Memory access pattern 
!        stride  : non-contiguous access with stride > 1
!        cont    : contiguous access (stride 1 access)
!        register: on register 
! ====================================================
! loop depth |     MC         MA         MB
!  j         | stride      register    stride 
!  k         | register    stride      cont  
!  i         | cont        cont        register 
!=========================================================================
   subroutine mmp_simple_blk (MC, MA, MB, ns, nbk1, nbk2)
     use mytype, only: DP
     implicit none
     integer,intent(in) :: ns, nbk1, nbk2
     real(kind=DP),intent(in) :: MA(ns,ns), MB(ns,ns)
     real(kind=DP),intent(out) :: MC(ns,ns)
   
     integer :: i, j, k, ii, kk
   
     MC(:,:) = 0.0_DP
     
     do kk = 1, ns, nbk2
     do ii = 1, ns, nbk1
   
     do j = 1, ns
     do k = kk, min(ns, kk+nbk2-1)
     do i = ii, min(ns, ii+nbk1-1)
           MC(i,j) = MC(i,j) + MA(i,k)*MB(k,j) 
     end do
     end do
     end do
   
     end do
     end do
   end subroutine mmp_simple_blk
end module mykernel
