! Copyright 2025 Research Organization for Information Science and Technology
!------------------------------------------------------------------------------
 
    program main

    use mpi

    implicit none

    integer, parameter :: input_no = 10
    character(len=132) argv
    character(len=132) input_file
    character(len=132) output_file
    logical :: file_exist

    integer :: array_size
    real(kind=8), allocatable :: A(:)
    integer :: ii
    integer :: n_loop
    integer :: i_skip

    !!! for MPI
    integer :: ierr
    integer :: nprocs, myrank
    integer :: ifh
    integer(kind=MPI_OFFSET_KIND) offset
    integer, parameter :: main_rank = 0

    !!! for elapse time measurement
    real(kind=8) :: t1, t2
    real(kind=8) :: total1, total2

    call MPI_Init(ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, nprocs, ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, myrank, ierr)

    if (command_argument_count() >= 1) then
       call get_command_argument(1, argv)
       input_file = adjustl(argv)

       open (unit=input_no, file=input_file, status='old', action='read', iostat=ierr)

       if (ierr /= 0) then
          write(0,'("File Open Error: ", A)') input_file
          call MPI_Finalize(ierr)
          stop
       endif

       read (input_no, *) array_size
       read (input_no, *) n_loop
       read (input_no, *) i_skip
       read (input_no, '(A)') output_file

       close(unit=input_no)
    else
       array_size = 20
       n_loop = 100
       i_skip = 5
       output_file = 'output.dat'
    endif

600 format(1x,2(A,I6,2x),(A,I10,2x),(F8.3,1x,A,2x),2(A,I6,2x))

    if (myrank == main_rank) then
       write(6,600) 'NPROCS=',nprocs, &
                    'MYRANK=',myrank, &
                    'DATA_SIZE=',array_size, dble(array_size)*8.d0/(1024.d0*1024.d0),'MiB', &
                    'NLOOP=',n_loop, &
                    'ISKIP=',i_skip
    endif

    allocate(A(1:array_size), stat=ierr)
    if (ierr /= 0) then
       write(0,'("Allocation Error: stat = ",i2)') ierr
       call MPI_Abort(MPI_COMM_WORLD, 90, ierr)
       stop
    endif

    do ii = 1, array_size
       A(ii) = 1.d0 - 1.d0 / real(ii, kind=8)
    enddo

    call MPI_Barrier(MPI_COMM_WORLD, ierr)
    total1 = MPI_Wtime()

    do ii = 1, n_loop

       if (mod(ii, i_skip) == 0) then

          call MPI_Barrier(MPI_COMM_WORLD, ierr)
          t1 = MPI_Wtime()

          offset = (array_size * 8.d0) * myrank
          call MPI_File_open(MPI_COMM_WORLD, output_file, MPI_MODE_WRONLY+MPI_MODE_CREATE, MPI_INFO_NULL, ifh, ierr)
          call MPI_File_write_at(ifh, offset, A, array_size, MPI_REAL8, MPI_STATUS_IGNORE, ierr)
          call MPI_File_close(ifh, ierr)

          call MPI_Barrier(MPI_COMM_WORLD, ierr)
          t2 = MPI_Wtime()

          if (myrank == main_rank) &
             write(6,'(4x,"II=",i6,2x,"ELAPSED(SEC)=",1PE15.6)') ii, t2-t1
       endif
    enddo

    call MPI_Barrier(MPI_COMM_WORLD, ierr)
    total2 = MPI_Wtime()
    if (myrank == main_rank) &
       write(6,'("NPROCS=",i6,2x,"TOTAL ELAPSED(SEC)=",1PE15.6)') nprocs, total2 - total1

    deallocate(A)
    call MPI_Finalize(ierr)

end program main
