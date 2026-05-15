#!/bin/bash
export fcc_ENV=-Nclang
export FCC_ENV=-Nclang
CC=mpifccpx CXX=mpiFCCpx make -f Makefile IMB-MPI1
CC=mpifccpx CXX=mpiFCCpx make -f Makefile IMB-MT
