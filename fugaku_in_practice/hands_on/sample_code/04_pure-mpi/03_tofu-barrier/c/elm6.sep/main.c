/* Copyright 2024 Research Organization for Information Science and Technology */
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>
#include "timer.h"

/* dummy kernel of task */
void do_task(int dummy, int m, double u, double *a)
{
   a[0] = u; 
   a[1] = u + 1*m; 
   a[2] = u + 2*m; 
   a[3] = u + 3*m; 
   a[4] = u + 4*m; 
   a[5] = u + 5*m; 
}

int main (int argc, char **argv)
{
  /* Initialize */
  MPI_Init(NULL, NULL);

  int np, me;
  MPI_Comm_size(MPI_COMM_WORLD, &np); /* number of processes */
  MPI_Comm_rank(MPI_COMM_WORLD, &me); /* my rank */

  if ( np <= 1 ) {
    if ( me == 0 ) {
       fprintf(stdout, "Error: This code does not work in a single-process setting.\n");
    }
    MPI_Finalize();
    return EXIT_FAILURE;
  }

  /* Splict communicator into two disjoint sub-groups
   * MPI_Comm_split(comm,color,key,newcomm)
   * [Layout]
   * sub-group 1: {0}
   * sub-group 2: {1, 2, ..., np-1}  */
  int mygroup = 1;
  if ( me == 0 ) mygroup = 0;
  MPI_Comm localcomm;
  MPI_Comm_split(MPI_COMM_WORLD, mygroup, 1, &localcomm);

  int np_loc, me_loc;
  MPI_Comm_size(localcomm, &np_loc); /* number of processes */
  MPI_Comm_rank(localcomm, &me_loc); /* my rank */

  /* Create inter-communicator 
   * MPI_Intercomm_Create(local_comm, local_leader, peer_comm, 
   *   remote_leader, tag, newintercomm) 
   * [Layout]
   * remote leader for sub-group 1: 1 in MPI_COMM_WORLD (=0 in sub-group 2)
   * remote leader for sub-group 2: 0 in MPI_COMM_WORLD (=0 in sub-group 1) */
  int mypartner = 0;
  if ( me == 0 ) mypartner = 1;
  int inter_group = 1;
  MPI_Comm workercomm;
  int np_partner;
  MPI_Intercomm_create(localcomm, 0, MPI_COMM_WORLD, mypartner, inter_group, &workercomm);
  MPI_Comm_remote_size(workercomm, &np_partner);
 
  /* Do measurement */
  double u_init;
  double A[6] = {0.0, 0.0, 0.0, 0.0, 0.0, 0.0};
  double elp0, elp;

  elp0 = get_elp_time();

  for ( int it = 0; it <=500000 ; ++it ) {

     /* main kernel */
     if ( me == 0 ) { 
        /* master */
        u_init = 0.0 + 1.0e-6*it;
        MPI_Bcast(&u_init, 1, MPI_DOUBLE, MPI_ROOT, workercomm);
     } else { 
        /* worker */
        MPI_Bcast(&u_init, 1, MPI_DOUBLE, 0, workercomm);

        double buff[6];
        do_task(it, me_loc, u_init, buff);

        MPI_Allreduce(&buff[0], &A[0], 3, MPI_DOUBLE, MPI_SUM, localcomm);
        MPI_Allreduce(&buff[3], &A[3], 3, MPI_DOUBLE, MPI_SUM, localcomm);
     }

     MPI_Barrier(MPI_COMM_WORLD);
  }

  elp = get_elp_time() - elp0;


  /* Dump log */
  FILE *fp;
  char fname[32];

  sprintf(fname, "log.%d", me);

  fp = fopen(fname, "w");
  fprintf(fp,"mygroup=%d\n", mygroup);
  fprintf(fp,"World: rank       =%d, size       =%d\n", me, np);
  fprintf(fp,"Split: rank(local)=%d, size(local)=%d\n", me_loc, np_loc);
  fprintf(fp,"Inter: size(remote)=%d\n", np_partner);
  fprintf(fp,"u_init =%f\n", u_init);
  for (int i = 0; i < 6; ++i ) {
    fprintf(fp,"A[%d] =%f\n", i, A[i]);
  }
  fprintf(fp, "Elapsed time of main part (s) = %.3f\n", elp);
  fclose(fp);

  /* Finalize  */
  MPI_Finalize();

  return EXIT_SUCCESS;
}
