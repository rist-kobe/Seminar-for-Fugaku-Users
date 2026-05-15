#!/bin/bash
#PJM --gname [project name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:03:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "simdif"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s


# Executable file 
BINDIR=..
EXE=${BINDIR}/run.x

# Execution
ulimit -s unlimited

NS=300  #Array size
TRATE=5 #To control true rate in if statement
${PERF} ${PERFOPT} ${PERFD}            \
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} \
${EXE} ${NS} ${TRATE} &> logfile.TRATE${TRATE}
echo " "

NS=300  #Array size
TRATE=15 #To control true rate in if statement
${PERF} ${PERFOPT} ${PERFD}            \
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} \
${EXE} ${NS} ${TRATE} &> logfile.TRATE${TRATE}
echo " "
