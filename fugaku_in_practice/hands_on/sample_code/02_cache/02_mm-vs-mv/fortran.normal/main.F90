! Copyright 2025 Research Organization for Information Science and Technology
program main
  use mytype,only: DP
  use mykernel,only: zero, one, initialize, mmp_simple
  use, intrinsic::iso_c_binding
  implicit none
#define NITR_MAX 10000
  integer,parameter :: iu_std = 6, iou_gen = 10
  integer :: i, j, it, incx, incy, ierr
  integer :: nargc, NSIZE, NITR

  character(len=32) :: cbuf

  real(kind=DP) :: gflop, gflops, tmp, diff, elp0, elp
  real(kind=DP), allocatable, dimension(:,:) :: mata
  real(kind=DP), allocatable, dimension(:,:) :: matb
  real(kind=DP), allocatable, dimension(:,:) :: matc
  real(kind=DP), allocatable, dimension(:,:) :: matcc

  interface

  real(kind=c_double) function get_elp_time() bind(c)
    use,intrinsic::iso_c_binding,only: c_double
  end function get_elp_time

  real(kind=c_double) function get_cpu_time() bind(c)
    use,intrinsic::iso_c_binding,only: c_double
  end function get_cpu_time

  end interface

  nargc = command_argument_count()
  if ( nargc .ne. 1 ) then
     write(iu_std,'(1A,/,1A)')                           &
&      "[usage] run.x (arg1) ",                          &
&      "        (arg1): matrix dimension (integer)"
     stop
  end if

  call get_command_argument(1,cbuf)
  read(cbuf,'(1I10)') NSIZE
  if ( NSIZE .le. 0 ) then
     write(iu_std, '(1A)') "Error: Matrix dimension must be a positive integer."
     stop
  end if

  allocate ( mata(1:NSIZE,1:NSIZE) )
  allocate ( matb(1:NSIZE,1:NSIZE) )
  allocate ( matc(1:NSIZE,1:NSIZE) )
  allocate ( matcc(1:NSIZE,1:NSIZE) )
 
  tmp = dble(NSIZE)
  gflop = 2.0_DP * tmp * tmp * tmp * 1.0E-9_DP

  NITR = NITR_MAX / NSIZE
  if ( NITR .lt. 5 ) then
     NITR = 5 
  else if ( NITR .lt. 50 ) then
     NITR = 10 * NITR
  else if ( NITR .lt. 100 ) then
     NITR = 20 * NITR
  else
     NITR = NITR_MAX
  end if 

  call initialize(matc, mata, matb, NSIZE)

  write(iu_std,'("kernel NSIZE NITR Elapsed_time_sec Gflop/s trace diff")')

!=========================================================================
! [Simple implementation]
!=========================================================================
  elp0 = get_elp_time()

  do it = 1, NITR
    call mmp_simple(matc, mata, matb, NSIZE)
    matc(1,1) = dble(it)*1.0E-9_DP
  end do

  elp = get_elp_time() - elp0

  gflops = (gflop*NITR) / elp

  diff = zero

  tmp = zero
  do i = 1, NSIZE
     tmp = tmp + matc(i,i)
  end do

  write(iu_std,'(1A10, 1I10, 1I10, 1F10.4, 1F10.4, 1E23.12, 1E29.18)') &
&    "simple", NSIZE, NITR, elp, gflops, tmp, diff

  matcc (:, :) = matc (:, :)
  matc (:, :) = zero
#if defined(CHECK_MATMUL) 
!=========================================================================
! [Fortran matmul]
!=========================================================================
  elp0 = get_elp_time()

  do it = 1, NITR
    matc = matmul(mata, matb)
    matc(1,1) = dble(it)*1.0E-9_DP
  end do

  elp = get_elp_time() - elp0

  gflops = (gflop*NITR) / elp

  diff = zero
  do i = 1, NSIZE
  do j = 1, NSIZE
     tmp = matc(i,j) - matcc(i,j)
     diff = diff + tmp*tmp
  end do
  end do
  diff = sqrt(diff)

  tmp = zero
  do i = 1, NSIZE
     tmp = tmp + matc(i,i)
  end do

  write(iu_std,'(1A10, 1I10, 1I10, 1F10.4, 1F10.4, 1E23.12, 1E29.18)') &
&    "matmul", NSIZE, NITR, elp, gflops, tmp, diff

  matc (:, :) = zero
#endif
!=========================================================================
! [DGEMM in (tuned) BLAS]
!=========================================================================
  elp0 = get_elp_time()

  do it = 1, NITR
    call DGEMM('N', 'N', NSIZE, NSIZE, NSIZE, one, mata, &
&          NSIZE, matb, NSIZE, zero, matc, NSIZE)
    matc(1,1) = dble(it)*1.0E-9_DP
  end do

  elp = get_elp_time() - elp0

  gflops = (gflop*NITR) / elp

  diff = zero
  do i = 1, NSIZE
  do j = 1, NSIZE
     tmp = matc(i,j) - matcc(i,j)
     diff = diff + tmp*tmp
  end do
  end do
  diff = sqrt(diff)

  tmp = zero
  do i = 1, NSIZE
     tmp = tmp + matc(i,i)
  end do

  write(iu_std,'(1A10, 1I10, 1I10, 1F10.4, 1F10.4, 1E23.12, 1E29.18)') &
&    "DGEMM", NSIZE, NITR, elp, gflops, tmp, diff

  matc (:, :) = zero
#if ! defined(CHECK_MATMUL) 
!=========================================================================
! [Repeated DGEMV in (tuned) BLAS]
!=========================================================================
  elp0 = get_elp_time()

  incx = 1
  incy = 1
  do it = 1, NITR
    do j = 1, NSIZE
       call DGEMV('N', NSIZE, NSIZE, one, mata, &
&             NSIZE, matb(:,j), incx, zero, matc(:,j), incy)
    end do
    matc(1,1) = dble(it)*1.0E-9_DP
  end do

  elp = get_elp_time() - elp0

  gflops = (gflop*NITR) / elp

  diff = zero
  do i = 1, NSIZE
  do j = 1, NSIZE
     tmp = matc(i,j) - matcc(i,j)
     diff = diff + tmp*tmp
  end do
  end do
  diff = sqrt(diff)

  tmp = zero
  do i = 1, NSIZE
     tmp = tmp + matc(i,i)
  end do

  write(iu_std,'(1A10, 1I10, 1I10, 1F10.4, 1F10.4, 1E23.12, 1E29.18)') &
&    "Rep-DGEMV", NSIZE, NITR, elp, gflops, tmp, diff

  matc (:, :) = zero
#endif

  stop 
end program main
