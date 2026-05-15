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
ulimit -s unlimited
${EXE} > logfile
