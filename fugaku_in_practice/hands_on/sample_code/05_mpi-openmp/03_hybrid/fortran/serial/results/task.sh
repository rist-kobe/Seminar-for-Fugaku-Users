#! /bin/bash
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
#PJM -L "node=1,elapse=02:00:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "hyb"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s


ulimit -s unlimited
EXE=../run.x

NPROCS=
MPIEXE= 

${EXE} 10000 10000
