/* Copyright 2024 Research Organization for Information Science and Technology */
#include <math.h>
#include "util.h"

/*-------------------------------------------------------------------
 * Utility functions
 * ----------------------------------------------------------------*/
void source_term (const int nxsize, const int nysize, double dx, double dy, int it, double * restrict s) 
{
   double c0 = 1.0;
   double c1 = 0.0;
   double c2 = -0.5;
   double c3 = 0.0;
   double c4 = 0.042;
   for ( int ix = 0; ix < nxsize; ++ix ) {
      double x = ix*dx;
      double u = (((c4*x + c3)*x + c2)*x + c1)*x + c0;
   for ( int iy = 0; iy < nysize; ++iy ) {
      double y = iy*dy;
      double v = (((c4*y + c3)*y + c2)*y + c1)*y + c0;
      int i = iy + nysize*ix;
      s[i] = u*v*cos(it*1.0e-6);
   }}
}

void forward_dx (const int nxsize, const int nysize, double * restrict f, double * restrict fd)
{
   for ( int ix = 0; ix < nxsize-1; ++ix ) {
   for ( int iy = 0; iy < nysize  ; ++iy ) {
      int i  = iy + nysize*ix;
      int ii = i + nysize;
      fd[i] = f[ii] - f[i]; /* fd[ix][iy] = f[ix+1][iy] - f[ix][iy] */
   }}
}

void forward_dy (const int nxsize, const int nysize, double * restrict f, double * restrict fd)
{
   for ( int ix = 0; ix < nxsize  ; ++ix ) {
   for ( int iy = 0; iy < nysize-1; ++iy ) {
      int i  = iy + nysize*ix;
      int ii = i + 1; 
      fd[i] = f[ii] - f[i]; /* fd[ix][iy] = f[ix][iy+1] - f[ix][iy] */
   }}
}

void bc_x (const int nxsize, const int nysize, double * restrict fd)
{
   int ix = nxsize - 1;
   for ( int iy = 0; iy < nysize; ++iy ) {
      int i  = iy + nysize*ix;
      fd[i] = 0.0;
   }
}

void bc_y (const int nxsize, const int nysize, double * restrict fd)
{
   int iy = nysize - 1;
   for ( int ix = 0; ix < nxsize; ++ix ) {
      int i  = iy + nysize*ix;
      fd[i] = 0.0;
   }
}
