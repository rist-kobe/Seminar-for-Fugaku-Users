#!/bin/bash
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:03:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "poly"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s


# Executable file 
BINDIR=..
EXE=${BINDIR}/run.x

# Execution
PERF=fapp
PERFD=fappd
PERFOPT=$(echo "-C -Icpupa,nompi -Hevent=statistics -L4 -d ${PERFD}")
#PERFOPT=$(echo "-C -Icpupa,mpi -Hevent=statistics -L4 -d ${PERFD}")

ulimit -s unlimited
${PERF} ${PERFOPT} ${EXE} > logfile
