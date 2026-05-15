#!/bin/bash
#PJM --gname [project name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1,elapse=00:07:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "memrd"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s


BINDIR=../../00_lmbench/lmbench-3.0-a9/bin/aarch64-linux-gnu
EXE=${BINDIR}/lat_mem_rd
CMDOPT=$(echo "-P 1 256 64 128 256 512 1024")
LOGFILE=$(echo "P1.256MB")

ulimit -s unlimited
numactl --physcpubind=12 --localalloc ${EXE} ${CMDOPT} &> ${LOGFILE}
