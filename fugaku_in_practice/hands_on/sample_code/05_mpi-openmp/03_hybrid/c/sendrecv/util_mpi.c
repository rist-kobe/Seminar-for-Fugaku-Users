/* Copyright 2024 Research Organization for Information Science and Technology */
#include <math.h>
#include "util_mpi.h"
/*-------------------------------------------------------------------
 * Utility functions: start
 * ----------------------------------------------------------------*/
void source_term_mpi (const int nxsize_local, const int nysize_local, 
   const int offset_x, const int offset_y, double dx, double dy, int it, 
   double * restrict s) 
{
   double c0 = 1.0;
   double c1 = 0.0;
   double c2 = -0.5;
   double c3 = 0.0;
   double c4 = 0.042;
   for ( int ix = 0; ix < nxsize_local; ++ix ) {
      double x = (ix+offset_x)*dx;
      double u = (((c4*x + c3)*x + c2)*x + c1)*x + c0;
   for ( int iy = 0; iy < nysize_local; ++iy ) {
      double y = (iy+offset_y)*dy;
      double v = (((c4*y + c3)*y + c2)*y + c1)*y + c0;
      int i = iy + nysize_local*ix;
      s[i] = u*v*cos(it*1.0e-6);
   }}
}

void forward_dx_mpi (const int nxsize_local1, const int nxsize_local, 
   const int nysize_local, double * restrict fend, 
   double * restrict f, double * restrict fd)
{
   for ( int ix = 0; ix < nxsize_local1; ++ix ) {
   for ( int iy = 0; iy < nysize_local ; ++iy ) {
      int i  = iy + nysize_local*ix;
      int ii = i + nysize_local;
      fd[i] = f[ii] - f[i]; /* fd[ix][iy] = f[ix+1][iy] - f[ix][iy] */
   }}

   int ix = nxsize_local1;
   for ( int iy = 0; iy < nysize_local ; ++iy ) {
      int i  = iy + nysize_local*ix;
      fd[i] = fend[iy] - f[i];
   }
}

void forward_dy_mpi (const int nysize_local1, const int nxsize_local, 
   const int nysize_local, double * restrict fend, 
   double * restrict f, double * restrict fd)
{
   for ( int ix = 0; ix < nxsize_local ; ++ix ) {
   for ( int iy = 0; iy < nysize_local1; ++iy ) {
      int i  = iy + nysize_local*ix;
      int ii = i + 1; 
      fd[i] = f[ii] - f[i]; /* fd[ix][iy] = f[ix][iy+1] - f[ix][iy] */
   }}

   int iy = nysize_local1;
   for ( int ix = 0; ix < nxsize_local ; ++ix ) {
      int i  = iy + nysize_local*ix;
      fd[i] = fend[ix] - f[i];
   }
}

void bc_x_mpi (const int nxsize_local, const int nysize_local, 
   double * restrict fd)
{
   int ix = nxsize_local - 1;
   for ( int iy = 0; iy < nysize_local; ++iy ) {
      int i  = iy + nysize_local*ix;
      fd[i] = 0.0;
   }
}

void bc_y_mpi (const int nxsize_local, const int nysize_local, 
   double * restrict fd)
{
   int iy = nysize_local - 1;
   for ( int ix = 0; ix < nxsize_local; ++ix ) {
      int i  = iy + nysize_local*ix;
      fd[i] = 0.0;
   }
}
