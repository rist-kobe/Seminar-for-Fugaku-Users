! Copyright 2025 Research Organization for Sciecne and Techonlogy 
!-----------------------------------------------------------------

    program main

    use mpi

    implicit none

    integer :: array_size
    real(kind=8), allocatable :: A(:)

    integer :: unit_no = 20
    integer :: input_no = 10
    integer :: output_no
    character(len=132) :: argv
    character(len=132) :: input_file
    character(len=132) :: output_file

    integer :: ierr
    integer :: nprocs, myrank
    integer, parameter :: main_rank = 0

    integer :: n_loop
    integer :: ii
    integer :: i_skip
    real(kind=8) :: t1, t2
    real(kind=8) :: total1, total2
    real(kind=8) :: x


    call MPI_Init(ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, nprocs, ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, myrank, ierr)

    if (command_argument_count() >= 1) then
       call get_command_argument(1, argv)
       input_file = adjustl(argv)

       open (unit=input_no, file=input_file, status='old', iostat=ierr, action='read')

       if (ierr /= 0) then
          write(0,*) 'file open error'
          call MPI_Finalize(ierr)
          stop
       endif

       read(input_no,*) array_size
       read(input_no,*) n_loop
       read(input_no,*) i_skip
       read(input_no,'(A)') output_file

       close(unit=input_no) 

    else
       array_size = 20
       n_loop = 100
       i_skip = 10
       output_file = './output/output.txt'
    endif

600 format(1x,2(A,I6,2x),(A,I10,2x),(F8.3,1x,A,2x),2(A,I6,2x))

    if (myrank == main_rank) then
       write(6,600) 'NPROCS=',nprocs, &
                    'MYRANK=',myrank, &
                    'DATA_SIZE=',array_size, dble(array_size)*8.d0/(1024.d0*1024.d0),'MiB', &
                    'NLOOP=',n_loop, &
                    'ISKIP=',i_skip
    endif

    call add_myrank_to_filename(myrank, output_file)

    !!! setting of the array A
    allocate(A(1:array_size), stat=ierr)
    if (ierr /= 0) then
       write(0,'("Allocation Error: stat = ",i2)') ierr
       call MPI_Abort(MPI_COMM_WORLD, 90, ierr)
       stop
    endif

    do ii = 1, array_size
       A(ii) = 1.0d0 - 1.0d0 / real(ii, kind=8)
    enddo

    !!! calculation and file output
    output_no = unit_no + myrank

    call MPI_Barrier(MPI_COMM_WORLD, ierr)
    total1 = MPI_Wtime()
    do ii = 1, n_loop

       if (mod(ii, i_skip) == 0) then
          call MPI_Barrier(MPI_COMM_WORLD, ierr)
          t1 = MPI_Wtime()

          open (unit=output_no, file=output_file, status='replace', action='write', iostat=ierr, &
             form='unformatted', access='stream')

          if (ierr /= 0) then
             write(0,'("File Open Error:", A)') output_file
             deallocate(A)
             call MPI_Abort(MPI_COMM_WORLD, 99, ierr)
             stop
          endif

          write(output_no) A
          close(unit=output_no)

          call MPI_Barrier(MPI_COMM_WORLD, ierr)
          t2 = MPI_Wtime()
          if (myrank == main_rank) &
             write(6,'(4x,"II=",i6,2x,"ELAPSED(SEC)=",1PE15.6)') ii, t2-t1
       endif

    enddo

    call MPI_Barrier(MPI_COMM_WORLD, ierr)
    total2 = MPI_Wtime()

    if (myrank == main_rank) then
       write(6,'("MYRANK=",i6,2x,"TOTAL ELAPSED(SEC)=",1PE15.6)') &
           myrank, total2 - total1
    endif

    deallocate(A)
    call MPI_Finalize(ierr)

contains
   subroutine add_myrank_to_filename(myrank, output_file)

   implicit none

   integer, intent(in) :: myrank
   character(len=*), intent(inout) :: output_file

   character(len=4) :: c_rank
   character(len=10) :: file_ext
   integer :: period_pos


   write(c_rank,'(i0.4)') myrank
   period_pos = index(output_file, '.', back=.true.)
   file_ext = output_file(period_pos:len_trim(output_file))

   output_file = output_file(1:period_pos-1) // '_' // c_rank // trim(file_ext)

   end subroutine add_myrank_to_filename

end program main
