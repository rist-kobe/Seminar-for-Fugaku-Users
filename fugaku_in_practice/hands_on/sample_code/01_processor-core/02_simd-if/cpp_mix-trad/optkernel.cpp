// Copyright 2024 Research Organization for Information Science and Technology
#include "optkernel.h"

void gen_listvec_trad (int inum, double rcut2, double xt, double yt, double zt,
   int * __restrict__ il, double * __restrict__ x, 
   double * __restrict__ y, double * __restrict__ z, 
   int * __restrict__ il_, double * __restrict__ dx_, 
   double * __restrict__ dy_, double * __restrict__ dz_, 
   double * __restrict__ r2_, int &ei)
{
   int ei_ = 0.0;
  
   #pragma loop norecurrence
   #pragma loop novrec
   #pragma loop noalias
   #pragma loop simd 
   for (int i=0; i<inum; ++i) {
      const int ii = il[i];
      const double dx = xt - x[ii];
      const double dy = yt - y[ii];
      const double dz = zt - z[ii];
      const double r2 = dx*dx + dy*dy + dz*dz;
      if ( r2 < rcut2 ) {
         il_[ei_] = ii;
         dx_[ei_] = dx;         
         dy_[ei_] = dy;         
         dz_[ei_] = dz;         
         r2_[ei_] = r2;
         ei_ += 1;
      }
   }
   ei = ei_;
}
