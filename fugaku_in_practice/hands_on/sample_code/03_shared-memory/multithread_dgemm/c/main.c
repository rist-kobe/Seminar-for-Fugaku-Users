/* Copyright 2025 Research Organization for Information Science and Technology */
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "mykernel.h"
#include "timer.h"

#include "cblas.h"
#include <omp.h>

#define NITR_MAX 10000

int main (int argc, char *argv[])
{
  int NSIZE, NITR, nt;
  int incx, incy;
  double zero = 0.0;
  double one  = 1.0;
  double tmp, elp0, elp, gflop, gflops;
  double *mata, *matb, *matc;

  if ( argc != 2 ) {
     printf("[usage] run.x (arg1) \n");
     printf("        (arg1): matrix dimension (integer)\n");
     return EXIT_SUCCESS;
  }

  NSIZE = atoi(argv[1]);

  mata = (double *) malloc ( NSIZE*NSIZE*sizeof(double) );
  matb = (double *) malloc ( NSIZE*NSIZE*sizeof(double) );
  matc = (double *) malloc ( NSIZE*NSIZE*sizeof(double) );

  nt = omp_get_max_threads();

  tmp = (double)NSIZE;
  gflop = 2.0 * tmp * tmp * tmp * 1.0e-9;

  NITR = NITR_MAX / NSIZE;
  if ( NITR < 5 ) {
     NITR = 5;
  } else if ( NITR < 50 ) {
     NITR = 10 * NITR;
  } else if ( NITR < 100 ) {
     NITR = 20 * NITR;
  } else {
     NITR = NITR_MAX;
  }

  {
     tmp = 1.0 / NSIZE;
     #pragma omp parallel for collapse(2) shared(mata,matb,matc,tmp)
     for ( int i = 0; i < NSIZE; ++i ) {
     for ( int j = 0; j < NSIZE; ++j ) {
         int ji = j + NSIZE*i;
         mata[ji] = (i - 0.5*NSIZE)*tmp;
         matb[ji] = (j - 0.5*NSIZE)*tmp;
	 matc[ji] = 0.0;
     }}
  }

  printf("kernel nthreads NSIZE NITR Elapsed_time_sec Gflop/s trace\n"); 

  /*====================================================================
   * [DGEMM in (tuned) BLAS]
   *====================================================================*/
  elp0 = get_elp_time();

  for ( int it = 0; it < NITR; ++it) {
     cblas_dgemm (CblasRowMajor, CblasNoTrans, CblasNoTrans, NSIZE, NSIZE, NSIZE, 
        one, &mata[0], NSIZE, &matb[0], NSIZE, zero, &matc[0], NSIZE);
     matc[0] = (double)it * 1.0e-9;
  }

  elp  = get_elp_time() - elp0;

  tmp = zero;
  for ( int i = 0; i < NSIZE; ++i) {
     int ji = i + NSIZE*i;
     tmp += matc[ji];
  }
 
  gflops = (gflop*NITR) / elp;

  printf("%10s %10d %10d %10d %10.4f %10.4f %23.12e\n", "DGEMM", nt, NSIZE, NITR, elp, gflops, tmp);

  return EXIT_SUCCESS;
}
