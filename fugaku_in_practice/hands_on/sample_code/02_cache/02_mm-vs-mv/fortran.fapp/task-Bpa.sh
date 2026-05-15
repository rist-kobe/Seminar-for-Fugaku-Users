#!/bin/bash
#PJM --gname [project name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:04:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "mm"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s


# Executable file 
BINDIR=..
EXE=${BINDIR}/run.x

# For Brief PA
ulimit -s unlimited

NS=800
NUMAC=$(echo "numactl --cpunodebind=4 --localalloc ")
${NUMAC} fapp -C -Icpupa,nompi -Hevent=pa1,mode=user -L4 -d fappd1 ${EXE} ${NS}
${NUMAC} fapp -C -Icpupa,nompi -Hevent=pa2,mode=user -L4 -d fappd2 ${EXE} ${NS}
${NUMAC} fapp -C -Icpupa,nompi -Hevent=pa3,mode=user -L4 -d fappd3 ${EXE} ${NS} 
${NUMAC} fapp -C -Icpupa,nompi -Hevent=pa4,mode=user -L4 -d fappd4 ${EXE} ${NS}
${NUMAC} fapp -C -Icpupa,nompi -Hevent=pa5,mode=user -L4 -d fappd5 ${EXE} ${NS}
