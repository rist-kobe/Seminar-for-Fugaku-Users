/* Copyright 2024 Research Organization for Information Science and Technology */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "timer.h"
#include "util_mpi.h"

#include <mpi.h>
#include <omp.h>

#define NITR 10000

#define MAX(a, b) ( (a) < (b) ? (b) : (a) )

/*-------------------------------------------------------------------
 * Main function
 * ----------------------------------------------------------------*/
int main (int argc, char **argv)
{
  int np, npx, npy, me, provided;
  int ntd;

  int nxsize, nysize;
  int it;

  double *f;
  double *fdx, *fdy;
  double *s; 

  if ( argc == 5 ) {
     nxsize = atoi(argv[1]);
     nysize = atoi(argv[2]);
     npx = atoi(argv[3]);
     npy = atoi(argv[4]);
  } else {
     nxsize = 10; 
     nysize = 1000; 
     npx = 1;
  } 

  /*-------------------------------------------------------------------
   * MPI setting
   *-----------------------------------------------------------------*/
  MPI_Init_thread(NULL, NULL, MPI_THREAD_SERIALIZED, &provided);
  MPI_Comm_size(MPI_COMM_WORLD, &np);
  MPI_Comm_rank(MPI_COMM_WORLD, &me);
  if ( MPI_THREAD_SERIALIZED < provided ) {
     if ( me == 0 ) {
        fprintf(stdout,"Error: Please check thread level in your MPI\n");
        fprintf(stdout,"Required: %d\n", MPI_THREAD_SERIALIZED);
        fprintf(stdout,"Provided: %d\n", provided);
     }
     MPI_Finalize();
     return EXIT_FAILURE;
  }
  if ( npx == 1 ) npy = np;
  if ( np != npx*npy ) {
     if ( me == 0 ) {
        fprintf(stdout,"Error: npx * npy must be equal to the number of MPI processes.\n");
        fprintf(stdout,"Your npx (=3rd arg): %d\n", npx);
        fprintf(stdout,"Your npy (=4th arg): %d\n", npy);
     }
     MPI_Finalize();
     return EXIT_FAILURE;
  }

  ntd = omp_get_max_threads();
  if ( ntd != 2 ) {
     if ( me == 0 ) {
        fprintf(stdout,"Error: Number of threads must be equal to 2.\n");
     }
     MPI_Finalize();
     return EXIT_FAILURE;
  }

  /* 2D Cartesian topology */
  int ndims, reorder;
  int dims[2], periods[2], coords[2];
  MPI_Comm cartComm;

  ndims = 2;
  periods[0] = 0;
  periods[1] = 0;
  reorder = 0;
  dims[0] = npx;
  dims[1] = npy;
  /* Use of Dims_create would be preferable 
   * MPI_Dims_create(np,ndims, dims); */

  MPI_Cart_create(MPI_COMM_WORLD, ndims, &dims[0], &periods[0], reorder, &cartComm);
  MPI_Cart_coords(cartComm, me, 2, coords);

  int disp_x, disp_y, rank_src_x, rank_dest_x, rank_src_y, rank_dest_y;
  disp_x = -1; /* downwards */
  disp_y = -1; /* downwards */
  MPI_Cart_shift(cartComm, 0, disp_x, &rank_src_x, &rank_dest_x);
  MPI_Cart_shift(cartComm, 1, disp_y, &rank_src_y, &rank_dest_y);

  /* Decomposition */
  int q, r;
  int nxsize_local, nxsize_local1, offset_x;
  int nysize_local, nysize_local1, offset_y;
  q = nxsize / dims[0];
  r = nxsize % dims[0];
  if ( coords[0] < r ) {
     nxsize_local = q + 1;
     offset_x = 0 + coords[0]*nxsize_local;
  } else {
     nxsize_local = q;
     offset_x = 0 + coords[0]*nxsize_local + r;
  }
  nxsize_local1 = nxsize_local - 1;

  q = nysize / dims[1];
  r = nysize % dims[1];
  if ( coords[1] < r ) {
     nysize_local = q + 1;
     offset_y = 0 + coords[1]*nysize_local;
  } else {
     nysize_local = q;
     offset_y = 0 + coords[1]*nysize_local + r;
  }
  nysize_local1 = nysize_local - 1;

  int max_buffer_size;
  q = (nxsize/npx) + 1;
  r = (nysize/npy) + 1;
  max_buffer_size = MAX(q, r);

  /* For p2p communication */
  double *send_buff_x, *recv_buff_x;
  double *send_buff_y, *recv_buff_y;
  int tag;
  MPI_Status status; 
  tag = 999;
  send_buff_x = (double *) malloc ( max_buffer_size*sizeof(double) );
  recv_buff_x = (double *) malloc ( max_buffer_size*sizeof(double) );
  send_buff_y = (double *) malloc ( max_buffer_size*sizeof(double) );
  recv_buff_y = (double *) malloc ( max_buffer_size*sizeof(double) );
  for ( int i = 0 ; i < max_buffer_size; ++i ) {
    send_buff_x[i] = 0.0;
    recv_buff_x[i] = 0.0;
    send_buff_y[i] = 0.0;
    recv_buff_y[i] = 0.0;
  }

  /*-------------------------------------------------------------------
   * Initialization 
   *-----------------------------------------------------------------*/
  double dx, dy;
  dx = 1.0 / (nxsize - 1);
  dy = 1.0 / (nysize - 1);

  f   = (double *) malloc ( nxsize_local*nysize_local*sizeof(double) );
  fdx = (double *) malloc ( nxsize_local*nysize_local*sizeof(double) );
  fdy = (double *) malloc ( nxsize_local*nysize_local*sizeof(double) );
  s   = (double *) malloc ( nxsize_local*nysize_local*sizeof(double) );

  for ( int ix = 0; ix < nxsize_local ; ++ix ) {
  for ( int iy = 0; iy < nysize_local ; ++iy ) {
     int i = iy + nysize_local*ix;
     f[i] = 0.0;
  }}

  #pragma omp parallel num_threads(2)
  {
     int tid = omp_get_thread_num();

     #pragma omp for schedule(static)
     for ( int iy = 0; iy < nysize_local; ++iy ) {
        int i = iy;
        send_buff_x[iy] = f[i];
     }

     #pragma omp for schedule(static)
     for ( int ix = 0; ix < nxsize_local; ++ix ) {
        int i = 0 + nysize_local*ix;
        send_buff_y[ix] = f[i];
     }

     if ( tid == 0 ) {
       /* p2p communication along x-direction */ 
       MPI_Sendrecv(&send_buff_x[0], nysize_local, MPI_DOUBLE, rank_dest_x, tag,
               &recv_buff_x[0], nysize_local, MPI_DOUBLE, rank_src_x , tag, 
               cartComm, &status);
       forward_dx_mpi (nxsize_local1,nxsize_local,nysize_local, &recv_buff_x[0], f, fdx);
       /* p2p communication along y-direction */ 
       MPI_Sendrecv(&send_buff_y[0], nxsize_local, MPI_DOUBLE, rank_dest_y, tag,
               &recv_buff_y[0], nxsize_local, MPI_DOUBLE, rank_src_y , tag, 
               cartComm, &status);
       forward_dy_mpi (nysize_local1,nxsize_local,nysize_local, &recv_buff_y[0], f, fdy);
     } else {
       /* calculate source term */
       source_term_mpi (nxsize_local, nysize_local, offset_x, offset_y, dx, dy, 0, s);
     }
  }

  /* boundary condition */
  if ( coords[0] == npx -1 ) {
     bc_x_mpi (nxsize_local, nysize_local, fdx);
  }
  if ( coords[1] == npy -1 ) {
     bc_y_mpi (nxsize_local, nysize_local, fdy);
  }

  /*-------------------------------------------------------------------
   * Main loop 
   *-----------------------------------------------------------------*/
  double elp0, elp;

  MPI_Barrier(MPI_COMM_WORLD);
  elp0 = get_elp_time();

  for ( it = 1; it <= NITR ; ++it ) {

    /* update */
    for ( int ix = 0; ix < nxsize_local ; ++ix ) {
    for ( int iy = 0; iy < nysize_local ; ++iy ) {
       int i = iy + nysize_local*ix;
       f[i] = s[i] + 0.25*fdx[i] + 0.25*fdy[i];
    }}

  #pragma omp parallel num_threads(2)
  {
     int tid = omp_get_thread_num();

     #pragma omp for schedule(static)
     for ( int iy = 0; iy < nysize_local; ++iy ) {
        int i = iy;
        send_buff_x[iy] = f[i];
     }

     #pragma omp for schedule(static)
     for ( int ix = 0; ix < nxsize_local; ++ix ) {
        int i = 0 + nysize_local*ix;
        send_buff_y[ix] = f[i];
     }

     if ( tid == 0 ) {
       /* p2p communication along x-direction */ 
       MPI_Sendrecv(&send_buff_x[0], nysize_local, MPI_DOUBLE, rank_dest_x, tag,
               &recv_buff_x[0], nysize_local, MPI_DOUBLE, rank_src_x , tag, 
               cartComm, &status);
       /* p2p communication along y-direction */ 
       MPI_Sendrecv(&send_buff_y[0], nxsize_local, MPI_DOUBLE, rank_dest_y, tag,
               &recv_buff_y[0], nxsize_local, MPI_DOUBLE, rank_src_y , tag, 
               cartComm, &status);
       forward_dx_mpi (nxsize_local1,nxsize_local,nysize_local, &recv_buff_x[0], f, fdx);
       forward_dy_mpi (nysize_local1,nxsize_local,nysize_local, &recv_buff_y[0], f, fdy);
     } else {
       /* calculate source term */
       source_term_mpi (nxsize_local, nysize_local, offset_x, offset_y, dx, dy, it, s);
     }
  }

    /* boundary condition */
    if ( coords[0] == npx -1 ) {
       bc_x_mpi (nxsize_local, nysize_local, fdx);
    }
    if ( coords[1] == npy -1 ) {
       bc_y_mpi (nxsize_local, nysize_local, fdy);
    }
  }

  MPI_Barrier(MPI_COMM_WORLD);
  elp = get_elp_time() - elp0;

  /*-------------------------------------------------------------------
   * Finalization 
   *-----------------------------------------------------------------*/
  double v = 0.0;
  for ( int ix = 0; ix < nxsize_local ; ++ix ) {
  for ( int iy = 0; iy < nysize_local ; ++iy ) {
     int i = iy + nysize_local*ix;
     v += f[i]*f[i]*dx*dy; 
  }}

  double vtot;
  MPI_Reduce(&v, &vtot, 1, MPI_DOUBLE, MPI_SUM, 0, MPI_COMM_WORLD);

  if ( me == 0 ) {
     fprintf(stdout,"Elapsed time of main loop (s): %11.4f\n", elp);
     fprintf(stdout,"Dummy output :%19.8e\n", vtot);
  }

  MPI_Finalize();
  return EXIT_SUCCESS;  
}
