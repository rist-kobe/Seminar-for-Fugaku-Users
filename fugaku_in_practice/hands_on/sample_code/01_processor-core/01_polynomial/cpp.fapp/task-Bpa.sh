#!/bin/bash
#PJM --gname [project name]
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

# For Brief PA
ulimit -s unlimited

NUMAC=$(echo "numactl --cpunodebind=4 --localalloc ")
${NUMAC} fapp -C -Icpupa,nompi -Hevent=pa1,mode=user -L4 -d fappd1 ${EXE} &> logfile.1
${NUMAC} fapp -C -Icpupa,nompi -Hevent=pa2,mode=user -L4 -d fappd2 ${EXE} &> logfile.2
${NUMAC} fapp -C -Icpupa,nompi -Hevent=pa3,mode=user -L4 -d fappd3 ${EXE} &> logfile.3
${NUMAC} fapp -C -Icpupa,nompi -Hevent=pa4,mode=user -L4 -d fappd4 ${EXE} &> logfile.4
${NUMAC} fapp -C -Icpupa,nompi -Hevent=pa5,mode=user -L4 -d fappd5 ${EXE} &> logfile.5
