// Copyright 2024 Research Organization for Information Science and Technology
#include "mykernel.h"
#include "optkernel.h"
#include <cmath>

void MyKernel::calc1 (int inum, double rcut2, double * _restrict_cpp g, double &f)
{
   setup();

   f = 0.0;

   for (int i=0; i<inum; ++i) {
      const int ii = il[i];
      const double dx = xt - x[ii];
      const double dy = yt - y[ii];
      const double dz = zt - z[ii];
      const double r2 = dx*dx + dy*dy + dz*dz;
      if ( r2 < rcut2 ) {
        const double u = exp(-0.5*r2/rcut2);
        g[ii] = x[ii] + y[ii] + z[ii] + u; 
      }
   }
}

void MyKernel::calc2 (int inum, double rcut2, double * _restrict_cpp g, double &f)
{
   setup();

   double f_ = 0.0;

   for (int i=0; i<inum; ++i) {
      const int ii = il[i];
      const double dx = xt - x[ii];
      const double dy = yt - y[ii];
      const double dz = zt - z[ii];
      const double r2 = dx*dx + dy*dy + dz*dz;
      if ( r2 < rcut2 ) {
        const double u = exp(-0.5*r2/rcut2);
        g[ii] = x[ii] + y[ii] + z[ii] + u; 
        f_ += u*dx + u*dy + u*dz; 
      }
   }

   f = f_;
}

void MyKernel::calc2_mod (int inum, double rcut2, double * _restrict_cpp g, double &f)
{
   setup();

   int il_[MAXINUM];
   double dx_[MAXINUM];
   double dy_[MAXINUM];
   double dz_[MAXINUM];
   double r2_[MAXINUM];

   int ei = 0;

//#if defined(__CLANG_FUJITSU) 
//   #pragma clang loop vectorize(assume_safety)
//#elif __FUJITSU
//   #pragma loop norecurrence
//   #pragma loop novrec
//   #pragma loop noalias
//   #pragma loop simd 
//#endif
   for (int i=0; i<inum; ++i) {
      const int ii = il[i];
      const double dx = xt - x[ii];
      const double dy = yt - y[ii];
      const double dz = zt - z[ii];
      const double r2 = dx*dx + dy*dy + dz*dz;
      if ( r2 < rcut2 ) {
         il_[ei] = ii;
         dx_[ei] = dx;         
         dy_[ei] = dy;         
         dz_[ei] = dz;         
         r2_[ei] = r2;
         ei += 1;
      }
   }

   double f_ = 0.0;

   if ( ei < 8 ) {
#if defined(__CLANG_FUJITSU) 
      #pragma clang loop vectorize(disable)
#elif __FUJITSU
      #pragma loop nosimd
#endif
      for (int i=0; i < ei; ++i ){
         const int ii = il_[i];
         const double dx = dx_[i];
         const double dy = dy_[i];
         const double dz = dz_[i];
         const double r2 = r2_[i];
         const double u = exp(-0.5*r2/rcut2);
         g[ii] = x[ii] + y[ii] + z[ii] + u; 
         f_ += u*dx + u*dy + u*dz; 
      }
   } else {
//#if defined(__CLANG_FUJITSU) 
//      #pragma clang loop vectorize(assume_safety)
//#elif __FUJITSU
//      #pragma loop norecurrence
//      #pragma loop novrec
//      #pragma loop noalias
//      #pragma loop simd 
//#endif
      for (int i=0; i < ei; ++i ){
         const int ii = il_[i];
         const double dx = dx_[i];
         const double dy = dy_[i];
         const double dz = dz_[i];
         const double r2 = r2_[i];
         const double u = exp(-0.5*r2/rcut2);
         g[ii] = x[ii] + y[ii] + z[ii] + u; 
         f_ += u*dx + u*dy + u*dz; 
      }
   }

   f = f_;
}

void MyKernel::calc2_mod2 (int inum, double rcut2, double * _restrict_cpp g, double &f)
{
   setup();

   int il_[MAXINUM];
   double dx_[MAXINUM];
   double dy_[MAXINUM];
   double dz_[MAXINUM];
   double r2_[MAXINUM];

   int ei = 0;

   gen_listvec_trad (inum, rcut2, xt, yt, zt, 
      il, x, y, z, il_, dx_, dy_, dz_, r2_, ei);

   double f_ = 0.0;

   if ( ei < 8 ) {
#if defined(__CLANG_FUJITSU) 
      #pragma clang loop vectorize(disable)
#elif __FUJITSU
      #pragma loop nosimd
#endif
      for (int i=0; i < ei; ++i ){
         const int ii = il_[i];
         const double dx = dx_[i];
         const double dy = dy_[i];
         const double dz = dz_[i];
         const double r2 = r2_[i];
         const double u = exp(-0.5*r2/rcut2);
         g[ii] = x[ii] + y[ii] + z[ii] + u; 
         f_ += u*dx + u*dy + u*dz; 
      }
   } else {
//#if defined(__CLANG_FUJITSU) 
//      #pragma clang loop vectorize(assume_safety)
//#elif __FUJITSU
//      #pragma loop norecurrence
//      #pragma loop novrec
//      #pragma loop noalias
//      #pragma loop simd 
//#endif
      for (int i=0; i < ei; ++i ){
         const int ii = il_[i];
         const double dx = dx_[i];
         const double dy = dy_[i];
         const double dz = dz_[i];
         const double r2 = r2_[i];
         const double u = exp(-0.5*r2/rcut2);
         g[ii] = x[ii] + y[ii] + z[ii] + u; 
         f_ += u*dx + u*dy + u*dz; 
      }
   }

   f = f_;
}

void MyKernel::count_true (int inum, double rcut2, double &t_rate)
{
   setup();

   int ei = 0;
   for (int i=0; i<inum; ++i) {
      const int ii = il[i];
      const double dx = xt - x[ii];
      const double dy = yt - y[ii];
      const double dz = zt - z[ii];
      const double r2 = dx*dx + dy*dy + dz*dz;
      if ( r2 < rcut2 ) {
         ei += 1;
      }
   }

   t_rate = static_cast<double>(ei) / inum;
}

inline void MyKernel::setup()
{ 
  xt = 0.0;
  yt = 0.0;
  zt = 0.0;
}
