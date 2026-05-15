! Copyright 2024 Research Organization for Information Science and Technology
!*-------------------------------------------------------------------------
! * Check supported thread level in MPI
! * Reference
! * [1] Intel(R) MPI benchmark: 
! *     https://github.com/intel/mpi-benchmarks.git 
! *     (See, e.g., src_cpp/imb.cpp)
! * [2] HPC Programming Seminar: MPI (in Japanese): 
! *     https://www.hpci-office.jp/events/seminars/seminar_texts
!--------------------------------------------------------------------------
program main
  implicit none
  
  include 'mpif.h'

  integer :: narg
  integer :: thread_level, required, provided
  integer :: me, np, ierr

  character(len=128) :: cbuff

  narg = command_argument_count()

  if ( narg .ne. 1 ) then
     write(6, '("[usage] chk_thd_level (arg1)")')
     write(6, '("(arg1): 0, 1, 2, or 3")')
     write(6, '("   0: MPI_THREAD_SINGLE")')
     write(6, '("   1: MPI_THREAD_FUNNELED")')
     write(6, '("   2: MPI_THREAD_SERIALIZED")')
     write(6, '("   3: MPI_THREAD_MULTIPLE")')
     stop
  end if 

  ! Get required thread level
  call get_command_argument(1, cbuff)
  read(cbuff, '(1I10)') thread_level
 
  if ( thread_level .eq. 0 ) then
     ! Only one thread will execute.
     ! equivalent to MPI_Init 
     required = MPI_THREAD_SINGLE;
  else if ( thread_level .eq. 1 ) then
     ! Application must ensure that only the main 
     ! thread makes MPI calls */
     required = MPI_THREAD_FUNNELED;
  else if ( thread_level .eq. 2 ) then
     ! Multiple threads may make MPI calls, but 
     ! only one at a time: MPI calls are not made 
     ! concurrently from two distinct threa. */
     required = MPI_THREAD_SERIALIZED;
  else if ( thread_level .eq. 3 ) then
     ! Multiple threads may call MPI, with no restrictions.
     required = MPI_THREAD_MULTIPLE;
  else
     ! default: MPI_THREAD_SINGLE */
     required = MPI_THREAD_SINGLE;
  end if

  call MPI_INIT_THREAD (required, provided, ierr);
  call MPI_COMM_SIZE (MPI_COMM_WORLD, np, ierr);
  call MPI_COMM_RANK (MPI_COMM_WORLD, me, ierr);

  if ( required .gt. provided ) then
     if ( me .eq. 0 ) then
        write(6, '("Error: Required thread level is higher than the supported")')
        write(6, '("       one in your MPI")')
        call message(required, provided)
     end if
     call MPI_FINALIZE()
     stop
  end if

  if ( me .eq. 0 ) then
     write(6, '("Required thread level is acceptable for your MPI.")')
     call message(required, provided)
  end if

  call MPI_FINALIZE()
  stop
end program

subroutine message(required, provided)
  implicit none
  integer, intent(in) :: required
  integer, intent(in) :: provided

  write(6, '("Required level: ", 1I5)') required
  write(6, '("Provided level: ", 1I5)') provided
  write(6, '("  Each integer indicates:")')
  write(6, '("   * 0: MPI_THREAD_SINGLE")')
  write(6, '("   * 1: MPI_THREAD_FUNNELED")')
  write(6, '("   * 2: MPI_THREAD_SERIALIZED")')
  write(6, '("   * 3: MPI_THREAD_MULTIPLE")')
end subroutine message
