/* Copyright 2025 Research Organization for Information Science and Technology */
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "mykernel.h"
#include "timer.h"

#include "cblas.h"

#include <fj_tool/fapp.h>

#define NITR_MAX 10000

int main (int argc, char *argv[])
{
  int NSIZE, NITR;
  int incx, incy;
  double zero = 0.0;
  double one  = 1.0;
  double tmp, diff, elp0, elp, gflop, gflops;
  //double mata[NSIZE*NSIZE], matb[NSIZE*NSIZE], matc[NSIZE*NSIZE];
  double *mata, *matb, *matc, *matcc;

  if ( argc != 2 ) {
     printf("[usage] run.x (arg1) \n");
     printf("        (arg1): matrix dimension (integer)\n");
     return EXIT_SUCCESS;
  }

  NSIZE = atoi(argv[1]);

  mata = (double *) malloc ( NSIZE*NSIZE*sizeof(double) );
  matb = (double *) malloc ( NSIZE*NSIZE*sizeof(double) );
  matc = (double *) malloc ( NSIZE*NSIZE*sizeof(double) );
  matcc= (double *) malloc ( NSIZE*NSIZE*sizeof(double) );

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
     unsigned int seed = 409101;
     srand( seed );
     for ( int i = 0; i < NSIZE; ++i ) {
     for ( int j = 0; j < NSIZE; ++j ) {
         int ji = j + NSIZE*i;
         mata[ji] = (2.0*(double)rand()/RAND_MAX - one) * tmp;
         matb[ji] = (2.0*(double)rand()/RAND_MAX - one) * tmp;
	 matc[ji] = 0.0;
     }}
  }

  printf("kernel NSIZE NITR Elapsed_time_sec Gflop/s trace diff \n"); 

  /*====================================================================
   * [Simple implementation]
   *====================================================================*/
  elp0 = get_elp_time();
  fapp_start("simple", 1, 1); /* FJ fapp */

  for ( int it = 0; it < NITR; ++it) {
     mmp_simple(NSIZE, matc, mata, matb);
     matc[0] = (double)it * 1.0e-9;
  }

  fapp_stop("simple", 1, 1); /* FJ fapp */
  elp  = get_elp_time() - elp0;

  tmp = zero;
  for ( int i = 0; i < NSIZE; ++i) {
     int ji = i + NSIZE*i;
     tmp += matc[ji];
  }
 
  gflops = (gflop*NITR) / elp;

  diff = zero;

  printf("%10s %10d %10d %10.4f %10.4f %23.12e %29.18e\n", "simple", NSIZE, NITR, elp, gflops, tmp, diff);
  
  for ( int i = 0; i < NSIZE; ++i ) {
  for ( int j = 0; j < NSIZE; ++j ) {
      int ji = j + NSIZE*i;
      matcc[ji] = matc[ji];
      matc[ji] = 0.0;
  }}
  /*====================================================================
   * [DGEMM in (tuned) BLAS]
   *====================================================================*/
  elp0 = get_elp_time();
  fapp_start("dgemm", 1, 1); /* FJ fapp */

  for ( int it = 0; it < NITR; ++it) {
     cblas_dgemm (CblasRowMajor, CblasNoTrans, CblasNoTrans, NSIZE, NSIZE, NSIZE, 
        one, &mata[0], NSIZE, &matb[0], NSIZE, zero, &matc[0], NSIZE);
     matc[0] = (double)it * 1.0e-9;
  }

  fapp_stop("dgemm", 1, 1); /* FJ fapp */
  elp  = get_elp_time() - elp0;

  tmp = zero;
  for ( int i = 0; i < NSIZE; ++i) {
     int ji = i + NSIZE*i;
     tmp += matc[ji];
  }
 
  gflops = (gflop*NITR) / elp;

  diff = 0.0;
  for ( int i = 0; i < NSIZE; ++i ) {
  for ( int j = 0; j < NSIZE; ++j ) {
      int ji = j + NSIZE*i;
      double dd = matc[ji] - matcc[ji];
      diff += dd*dd;
  }}
  diff = sqrt(diff);

  printf("%10s %10d %10d %10.4f %10.4f %23.12e %29.18e\n", "DGEMM", NSIZE, NITR, elp, gflops, tmp, diff);

  for ( int i = 0; i < NSIZE; ++i ) {
  for ( int j = 0; j < NSIZE; ++j ) {
      int ji = j + NSIZE*i;
      matc[ji] = 0.0;
  }}

  /*====================================================================
   * [Repeated DGEMV in (tuned) BLAS]
   *====================================================================*/
  elp0 = get_elp_time();
  fapp_start("dgemv", 1, 1); /* FJ fapp */

  incx = 1; 
  incy = 1;

  double *vx, *vy;
 
  vx = (double *)malloc ( NSIZE*sizeof(double) );
  vy = (double *)malloc ( NSIZE*sizeof(double) );

  for ( int i = 0; i < NSIZE; ++i ) {
     vx[i] = 0.0;
     vy[i] = 0.0;
  }

  for ( int it = 0; it < NITR; ++it) {


     for ( int j = 0; j < NSIZE; ++j ) {

       /* pack buffer */
       for ( int i = 0; i < NSIZE; ++i ) {
	   int ji = j + NSIZE*i; 
           vx[i] = matb[ji];
       }

       cblas_dgemv (CblasRowMajor, CblasNoTrans, NSIZE, NSIZE, 
           one, &mata[0], NSIZE, &vx[0], incx, zero, &vy[0], incy);

       /* unpack buffer */
       for ( int i = 0; i < NSIZE; ++i ) {
	   int ji = j + NSIZE*i; 
           matc[ji] = vy[i];
       }

     }
     matc[0] = (double)it * 1.0e-9;
  }

  fapp_stop("dgemv", 1, 1); /* FJ fapp */
  elp  = get_elp_time() - elp0;

  tmp = zero;
  for ( int i = 0; i < NSIZE; ++i) {
     int ji = i + NSIZE*i;
     tmp += matc[ji];
  }
 
  gflops = (gflop*NITR) / elp;

  diff = 0.0;
  for ( int i = 0; i < NSIZE; ++i ) {
  for ( int j = 0; j < NSIZE; ++j ) {
      int ji = j + NSIZE*i;
      double dd = matc[ji] - matcc[ji];
      diff += dd*dd;
  }}
  diff = sqrt(diff);

  printf("%10s %10d %10d %10.4f %10.4f %23.12e %29.18e\n", "Rep-DGEMV", NSIZE, NITR, elp, gflops, tmp, diff);
  
  for ( int i = 0; i < NSIZE; ++i ) {
  for ( int j = 0; j < NSIZE; ++j ) {
      int ji = j + NSIZE*i;
      matc[ji] = 0.0;
  }}

  return EXIT_SUCCESS;
}
