/* Copyright 2024 Research Organization for Information Science and Technology */
#pragma once

void source_term_mpi (const int nxsize_local, const int nysize_local, 
   const int offset_x, const int offset_y, double dx, double dy, int it, 
   double * restrict s);

void forward_dx_mpi (const int nxsize_local1, const int nxsize_local, 
   const int nysize_local, double * restrict fend, 
   double * restrict f, double * restrict fd);

void forward_dy_mpi (const int nysize_local1, const int nxsize_local, 
   const int nysize_local, double * restrict fend, 
   double * restrict f, double * restrict fd);

void bc_x_mpi (const int nxsize_local, const int nysize_local, 
   double * restrict fd);

void bc_y_mpi (const int nxsize_local, const int nysize_local, 
   double * restrict fd);
