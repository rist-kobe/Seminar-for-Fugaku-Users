#!/bin/bash
#PJM --gname [project name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:06:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "strm"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s
env NTHREADS=1 bash run.sh
env NTHREADS=4 TAFF=close bash run.sh
env NTHREADS=8 TAFF=close bash run.sh
env NTHREADS=12 TAFF=close bash run.sh
env NTHREADS=24 TAFF=close bash run.sh
env NTHREADS=48 TAFF=close bash run.sh
