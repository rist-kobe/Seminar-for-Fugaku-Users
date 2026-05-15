! Copyright 2024 Research Organization for Information Science and Technology
! dummy kernel of task
subroutine do_task(dummy, m, u, a, n)
  implicit none
  integer, intent(in) :: dummy
  integer, intent(in) :: m
  integer, intent(in) :: n
  real(8), intent(in) :: u
  real(8), intent(out) :: a(1:n)

  a(1) = u
  a(2) = u + 1*m
  a(3) = u + 2*m
  a(4) = u + 3*m
  a(5) = u + 4*m
  a(6) = u + 5*m
end subroutine do_task

program main
  implicit none

  include 'mpif.h'

  integer :: ierr
  integer :: it
  integer :: np, me, np_loc, me_loc, np_partner
  integer :: mygroup, mypartner, inter_group
  integer :: localcomm, workercomm

  real(8) :: u_init
  real(8) :: elp0, elp
  real(8) :: A(6), buff(6)

  interface 
  real(kind=c_double) function get_elp_time() bind(c)
     use,intrinsic :: iso_c_binding,only: c_double
  end function get_elp_time
  end interface

  ! Initialize
  call MPI_INIT(ierr)
  call MPI_COMM_SIZE(MPI_COMM_WORLD, np, ierr) ! number of processes
  call MPI_COMM_RANK(MPI_COMM_WORLD, me, ierr) ! my rank

  if ( np .le. 1 ) then
     if ( me .eq. 0 ) then
        write(6,'(1A)') "Error: This code does not work in a single-process setting."
     end if
     call MPI_Finalize()
     stop
  end if

  ! Splict communicator into two disjoint sub-groups
  !  MPI_COMM_SPLIT(comm,color,key,newcomm,ierr)
  !  [Layout]
  !  sub-group 1: {0}
  !  sub-group 2: {1, 2, ..., np-1}  
  mygroup = 1
  if (me .eq. 0 ) then
     mygroup = 0
  end if
  call MPI_COMM_SPLIT(MPI_COMM_WORLD, mygroup, 1, localcomm, ierr)
  call MPI_COMM_SIZE(localcomm, np_loc, ierr) ! number of processes
  call MPI_COMM_RANK(localcomm, me_loc, ierr) ! my rank

  ! Create inter-communicator 
  !  MPI_INTERCOMM_CREATE(local_comm, local_leader, peer_comm, 
  !    remote_leader, tag, newintercomm,ierr) 
  !  [Layout]
  !  remote leader for sub-group 1: 1 in MPI_COMM_WORLD (=0 in sub-group 2)
  !  remote leader for sub-group 2: 0 in MPI_COMM_WORLD (=0 in sub-group 1) 
  mypartner = 0
  if (me .eq. 0 ) then
     mypartner = 1
  end if
  inter_group = 1
  call MPI_INTERCOMM_CREATE(localcomm, 0, MPI_COMM_WORLD, &
  &    mypartner, inter_group, workercomm, ierr);
  call MPI_COMM_REMOTE_SIZE(workercomm, np_partner,ierr);

  ! Do measurement
  A(:) = 0.0d0

  elp0 = get_elp_time()

  do it = 1, 500000

    ! main kernel
    if ( me .eq. 0 ) then 
       ! master
       u_init = 0.0D0 + 1.0D-6*it
       call MPI_BCAST(u_init, 1, MPI_DOUBLE, MPI_ROOT, workercomm, ierr)
    else 
       ! worker
       call MPI_BCAST(u_init, 1, MPI_DOUBLE, 0, workercomm, ierr)

       call do_task(it, me, u_init, buff, 6)

       call MPI_ALLREDUCE(buff, A, 6, MPI_DOUBLE, MPI_SUM, localcomm, ierr)
    end if

    call MPI_BARRIER(MPI_COMM_WORLD,ierr)

  end do

  elp = get_elp_time() - elp0

  ! Dump log
  BLOCK
  integer,parameter :: w_unit = 11
  integer :: i
  character(len=8) :: fname

  fname="log.0000"
  write(fname(5:8),'(1I0.4)') me

  open(w_unit, FILE=fname)
  write(w_unit,'("mygroup=",1I5)') mygroup
  write(w_unit,'("World: rank       =",1I5," size       =",1I5)') me, np
  write(w_unit,'("Split: rank(local)=",1I5," size(local)=",1I5)') me_loc, np_loc
  write(w_unit,'("Inter: size(remote)=",1I5)') np_partner
  write(w_unit,'("u_init =",1F)') u_init
  do i = 1, 6
     write(w_unit, '("A(",1I3,") =",1F14.5)') i, A(i)
  end do
  write(w_unit, '("Elapsed time of main part (s) = ",1F9.3)') elp
  close(w_unit)
  END BLOCK

  ! Finalize
  call MPI_FINALIZE(ierr)

  stop
end program
