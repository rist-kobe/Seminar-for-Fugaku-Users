// Copyright 2024 Research Organization for Information Science and Technology
#ifndef MYKERNEL_H
#define MYKERNEL_H

#if __CLANG_FUJITSU
#define _restrict_cpp __restrict__
#elif __FUJITSU
#define _restrict_cpp __restrict__
#elif __GNUC__
#define _restrict_cpp __restrict__
#elif
#define _restrict_cpp 
#endif

#define MAXINUM 2000

class MyKernel {
 public:
  int * il;
  double *x;
  double *y;
  double *z;
  void calc1(int, double, double * _restrict_cpp, double &f);
  void calc2(int, double, double * _restrict_cpp, double &f);
  void calc2_mod(int, double, double * _restrict_cpp, double &f);
  void calc2_mod2(int, double, double * _restrict_cpp, double &f);
  void count_true (int, double, double &);

 private:
  double xt;
  double yt;
  double zt;
  inline void setup();
};

#endif //MYKERNEL_H
