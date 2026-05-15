/* Copyright 2024 Research Organization for Information Science and Technology */
/*------------------------------------------------------------------------
 * Check supported thread level in MPI
 * Reference
 * [1] Intel(R) MPI benchmark: 
 *     https://github.com/intel/mpi-benchmarks.git 
 *     (See, e.g., src_cpp/imb.cpp)
 * [2] HPC Programming Seminar: MPI (in Japanese): 
 *     https://www.hpci-office.jp/events/seminars/seminar_texts
 -------------------------------------------------------------------------*/
#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

void message(int required, int provided)
{
  fprintf(stdout, "Required level: %d\n", required);
  fprintf(stdout, "Provided level: %d\n", provided);
  fprintf(stdout, "  Each integer indicates:\n");
  fprintf(stdout, "   * 0: MPI_THREAD_SINGLE\n");
  fprintf(stdout, "   * 1: MPI_THREAD_FUNNELED\n");
  fprintf(stdout, "   * 2: MPI_THREAD_SERIALIZED\n");
  fprintf(stdout, "   * 3: MPI_THREAD_MULTIPLE\n");
}

int main (int argc, char **argv)
{
   int required, provided;
   int me, np;

   if ( argc != 2 ) {
      fprintf(stdout,"[usage] chk_thd_level (arg1)\n");
      fprintf(stdout,"(arg1): 0, 1, 2, or 3\n");
      fprintf(stdout,"   0: MPI_THREAD_SINGLE is required.\n");
      fprintf(stdout,"   1: MPI_THREAD_FUNNELED is required.\n");
      fprintf(stdout,"   2: MPI_THREAD_SERIALIZED is required.\n");
      fprintf(stdout,"   3: MPI_THREAD_MULTIPLE is required.\n");
      return EXIT_SUCCESS;
   }

   /* Get required thread level */
   int thread_level = atoi(argv[1]);
   /*fprintf(stdout,"%d\n", required);*/

   if ( thread_level == 0 ) {
      /* Only one thread will execute.
       * equivalent to MPI_Init */
      required = MPI_THREAD_SINGLE;
   } else if ( thread_level == 1 ) {
      /* Application must ensure that only the main 
       * thread makes MPI calls */
      required = MPI_THREAD_FUNNELED;
   } else if ( thread_level == 2 ) {
      /* Multiple threads may make MPI calls, but 
       * only one at a time: MPI calls are not made 
       * concurrently from two distinct threa. */
      required = MPI_THREAD_SERIALIZED;
   } else if ( thread_level == 3 ) {
      /* Multiple threads may call MPI, with no restrictions. */
      required = MPI_THREAD_MULTIPLE;
   } else {
      /* default: MPI_THREAD_SINGLE */
      required = MPI_THREAD_SINGLE;
   }

   MPI_Init_thread (NULL, NULL, required, &provided);
   MPI_Comm_size(MPI_COMM_WORLD, &np);
   MPI_Comm_rank(MPI_COMM_WORLD, &me);

   if ( required > provided ) {
     if ( me == 0 ) {
        fprintf(stdout,"Error: Required thread level is higher than the supported one in your MPI.\n");
        message(required, provided); 
     }
     MPI_Finalize();
     return EXIT_FAILURE;
   }

   if ( me == 0 ) {
     fprintf(stdout,"Required thread level is acceptable for your MPI.\n");
     message(required, provided); 
   }

   MPI_Finalize();
   return EXIT_SUCCESS;
}
