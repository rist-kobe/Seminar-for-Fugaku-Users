/* Copyright 2024 Research Organization for Information Science and Technology */
#include <stdio.h>
#include <stdlib.h>

#include <mpi.h>
#include <omp.h>


int main (int argc, char **argv)
{
   int np, me, provided;

   MPI_Init_thread(NULL, NULL, MPI_THREAD_SINGLE, &provided);

   MPI_Comm_size(MPI_COMM_WORLD, &np); /* Num of processes */
   MPI_Comm_rank(MPI_COMM_WORLD, &me); /* Rank */

   FILE *fp;
   char fname[32];
   sprintf(fname,"chk.%04d",me);

   fp = fopen(fname,"w");

   fprintf(fp, "Rank = %d of %d MPI tasks\n", me, np);

   fprintf(fp, "   Start OpenMP parallel region\n");
   #pragma omp parallel
   {
      int tid = omp_get_thread_num();
      int ntd = omp_get_num_threads();
      #pragma omp critical
      {
         fprintf(fp, "   Thread = %d of %d OpenMP threads\n", tid, ntd);
      }
   }

   fclose(fp);

   MPI_Finalize();
   return EXIT_SUCCESS;
}
