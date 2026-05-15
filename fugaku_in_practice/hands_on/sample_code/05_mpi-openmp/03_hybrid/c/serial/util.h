/* Copyright 2024 Research Organization for Information Science and Technology */
#pragma once

/*-------------------------------------------------------------------
 * Utility functions
 * ----------------------------------------------------------------*/
void source_term (const int nxsize, const int nysize, double dx, double dy, int it, double * restrict s);

void forward_dx (const int nxsize, const int nysize, double * restrict f, double * restrict fd);

void forward_dy (const int nxsize, const int nysize, double *restrict f, double * restrict fd);

void bc_x (const int nxsize, const int nysize, double * restrict fd);

void bc_y (const int nxsize, const int nysize, double * restrict fd);
