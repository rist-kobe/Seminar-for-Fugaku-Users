#!/bin/bash
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:03:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "numa"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s
echo "--------------------------------------------"
echo "hostname"
hostname
echo "--------------------------------------------"

echo "--------------------------------------------"
echo "lscpu"
lscpu
echo "--------------------------------------------"

echo "--------------------------------------------"
echo "numactl -H"
numactl -H 
echo "--------------------------------------------"
