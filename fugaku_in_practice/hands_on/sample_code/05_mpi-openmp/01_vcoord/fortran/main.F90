! Copyright 2024 Research Organization for Information Science and Technology
program main
  use omp_lib
  implicit none

  include 'mpif.h'

  integer, parameter :: w_unit = 11
  integer :: np, me, provided, ierr
  integer :: tid, ntd
  character(len=32) :: fname

  call MPI_INIT_THREAD (MPI_THREAD_SINGLE, provided, ierr)
  call MPI_COMM_SIZE (MPI_COMM_WORLD, np, ierr)
  call MPI_COMM_RANK (MPI_COMM_WORLD, me, ierr)

  fname = "chk.0000"
  write (fname(5:8), '(1I0.4)') me

  open (w_unit, file=fname, status='unknown')

  write(w_unit, '("Rank =", 1I4," of ",1I4," MPI tasks")') me, np
  
  write(w_unit, '("   Start OpenMP parallel region")')
!$OMP PARALLEL PRIVATE(tid, ntd)
   tid = omp_get_thread_num()
   ntd = omp_get_num_threads()
!$OMP CRITICAL
   write(w_unit, '("   Thread =",1I4," of ",1I4," OpenMP threads")') &
   &   tid, ntd
!$OMP END CRITICAL
!$OMP END PARALLEL

  close(w_unit)

  call MPI_FINALIZE (ierr)
  stop
end program main
