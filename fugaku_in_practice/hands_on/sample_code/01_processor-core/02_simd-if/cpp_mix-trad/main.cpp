// Copyright 2024 Research Organization for Information Science and Technology
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include "mykernel.h"
#include "timer.h"

#define STRIDE_DP 4
#define NITR 100000
#define SCALEFAC 1.0e-1

int main (int argc, char **argv)
{
  int inum, itrue_rate; 
  double rcut2, t_rate;
  double elp0, elp[4]; 

  if ( argc != 3 ) {
    fprintf (stdout, "[usage] run.x (arg1) (arg2)\n");
    fprintf (stdout, "  (arg1): array size (integer)\n");
    fprintf (stdout, "  (arg2): true rate of if statement (integer)\n");
    fprintf (stdout, "          -1 means default (arg2=10).\n");
    fprintf (stdout, "          0 means no true case.\n");
    fprintf (stdout, "          Larger means more true.\n");
    return EXIT_SUCCESS;
  }

  inum = atoi(argv[1]);
  if ( inum <= 0 ) {
     inum = 200;
  }

  itrue_rate = atoi(argv[2]);
  if ( itrue_rate < 0 ) {
     itrue_rate = 10;
  }
  rcut2 = 0.5e-1 * itrue_rate * inum * SCALEFAC;
  rcut2 = rcut2 * rcut2;

  if ( inum > MAXINUM ) {
     fprintf(stdout, "Error: inum must be smaller than %d\n", MAXINUM);
     return EXIT_FAILURE;
  }

  // Data preparation
  MyKernel kernel;
  double *g;
  double f;

  kernel.x  = new double [inum];
  kernel.y  = new double [inum];
  kernel.z  = new double [inum];
  kernel.il = new int [inum];

  g = new double [inum];

  for (int i = 0; i < inum; ++i) {
     double tmp = 0.5*inum - i;
     tmp = tmp * SCALEFAC;
     kernel.x[i] = tmp;
     kernel.y[i] = tmp + SCALEFAC;
     kernel.z[i] = tmp + 2.0*SCALEFAC;
  }
  // for debug
  //for (int i = 0; i < inum; ++i ) {
  //   fprintf(stdout,"%i %f %f %f\n", i, kernel.x[i], kernel.y[i], kernel.z[i]);
  //}

  // Note: There is no overlap b/w the elements.
  for (int i = 0; i < inum; ++i) {
     int ii = i + STRIDE_DP;
     if ( ii >= inum ) {
        ii = ii - inum;
     }
     kernel.il[i] = ii;
  }
  // for debug
  //for (int i = 0; i < inum; ++i ) {
  //   fprintf(stdout,"%d %d\n", i, kernel.il[i]);
  //}

  // Check true rate in if statement
  kernel.count_true(inum, rcut2, t_rate); 

  // Kerel 1
  for ( int i = 0; i < inum; ++i ) {
     g[i] = 0.0;
  }

  f = 0.0; 

  elp0 = get_elp_time();
  for ( int it = 0; it < NITR; ++it ) {
     kernel.calc1(inum, rcut2, g, f); 
     g[0] = it*1.0e-9; // fake calculation
     f = it*1.0e-9; // fake calculation
  }
  elp[0] = get_elp_time() - elp0;

  // Kerel 2
  for ( int i = 0; i < inum; ++i ) {
     g[i] = 0.0;
  }

  f = 0.0; 

  elp0 = get_elp_time();
  for ( int it = 0; it < NITR; ++it ) {
     kernel.calc2(inum, rcut2, g, f); 
     g[0] = it*1.0e-9; // fake calculation
     f = it*1.0e-9; // fake calculation
  }
  elp[1] = get_elp_time() - elp0;

  // Kerel 2 mod
  for ( int i = 0; i < inum; ++i ) {
     g[i] = 0.0;
  }

  f = 0.0; 

  elp0 = get_elp_time();
  for ( int it = 0; it < NITR; ++it ) {
     kernel.calc2_mod(inum, rcut2, g, f); 
     g[0] = it*1.0e-9; // fake calculation
     f = it*1.0e-9; // fake calculation
  }
  elp[2] = get_elp_time() - elp0;

  // Kerel 2 mod2
  for ( int i = 0; i < inum; ++i ) {
     g[i] = 0.0;
  }

  f = 0.0; 

  elp0 = get_elp_time();
  for ( int it = 0; it < NITR; ++it ) {
     kernel.calc2_mod2(inum, rcut2, g, f); 
     g[0] = it*1.0e-9; // fake calculation
     f = it*1.0e-9; // fake calculation
  }
  elp[3] = get_elp_time() - elp0;

  // Check true rate in if statement
  //kernel.count_true(inum, rcut2, t_rate); 

  fprintf(stdout,"Array size : %d\n", inum);
  fprintf(stdout,"True rate  : %11.2f\n", t_rate);
  fprintf(stdout,"Elapsed time (sec.)\n");
  fprintf(stdout,"  Kernel 1     :  %12.3f\n", elp[0]);
  fprintf(stdout,"  Kernel 2     :  %12.3f\n", elp[1]);
  fprintf(stdout,"  Kernel 2 mod :  %12.3f\n", elp[2]);
  fprintf(stdout,"  Kernel 2 mod2:  %12.3f\n", elp[3]);
  fprintf(stdout,"Dummy output: %16.5f %16.5f\n", g[0], f);

  return EXIT_SUCCESS;
}
