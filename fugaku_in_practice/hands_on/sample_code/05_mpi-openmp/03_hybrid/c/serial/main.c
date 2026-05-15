/* Copyright 2024 Research Organization for Information Science and Technology */
#include <stdio.h>
#include <stdlib.h>
#include "timer.h"
#include "util.h"

#define NITR 10000

/*-------------------------------------------------------------------
 * Main function
 * ----------------------------------------------------------------*/
int main (int argc, char **argv)
{
  int nxsize, nysize;
  int it;

  double *f;
  double *fdx, *fdy;
  double *s; 

  if ( argc == 3 ) {
     nxsize = atoi(argv[1]);
     nysize = atoi(argv[2]);
  } else {
     nxsize = 100; 
     nysize = 100; 
  } 

  /*-------------------------------------------------------------------
   * Initialization 
   *-----------------------------------------------------------------*/
  double dx, dy;
  dx = 1.0 / (nxsize - 1);
  dy = 1.0 / (nysize - 1);

  f   = (double *) malloc ( nxsize*nysize*sizeof(double) );
  fdx = (double *) malloc ( nxsize*nysize*sizeof(double) );
  fdy = (double *) malloc ( nxsize*nysize*sizeof(double) );
  s   = (double *) malloc ( nxsize*nysize*sizeof(double) );

  for ( int ix = 0; ix < nxsize ; ++ix ) {
  for ( int iy = 0; iy < nysize ; ++iy ) {
     int i = iy + nysize*ix;
     f[i] = 0.0; /* f[ix][iy] = 0.0 */
  }}

  forward_dx (nxsize, nysize, f, fdx);
  forward_dy (nxsize, nysize, f, fdy);

  bc_x (nxsize, nysize, fdx);
  bc_y (nxsize, nysize, fdy);

  source_term (nxsize, nysize, dx, dy, 0, s);

  /*-------------------------------------------------------------------
   * Main loop 
   *-----------------------------------------------------------------*/
  double elp0, elp;

  elp0 = get_elp_time();

  for ( it = 1; it <= NITR ; ++it ) {

    for ( int ix = 0; ix < nxsize ; ++ix ) {
    for ( int iy = 0; iy < nysize ; ++iy ) {
       int i = iy + nysize*ix;
       f[i] = s[i] + 0.25*fdx[i] + 0.25*fdy[i];
    }}

    forward_dx (nxsize, nysize, f, fdx);
    forward_dy (nxsize, nysize, f, fdy);

    bc_x (nxsize, nysize, fdx);
    bc_y (nxsize, nysize, fdy);

    source_term (nxsize, nysize, dx, dy, it, s);
  }

  elp = get_elp_time() - elp0;

  /*-------------------------------------------------------------------
   * Finalization 
   *-----------------------------------------------------------------*/
  double v = 0.0;
  for ( int ix = 0; ix < nxsize ; ++ix ) {
  for ( int iy = 0; iy < nysize ; ++iy ) {
     int i = iy + nysize*ix;
     v += f[i]*f[i]*dx*dy; 
  }}

  fprintf(stdout,"Elapsed time of main loop (s): %11.4f\n", elp);
  fprintf(stdout,"Dummy output :%19.8e\n", v);

  return EXIT_SUCCESS;  
}
