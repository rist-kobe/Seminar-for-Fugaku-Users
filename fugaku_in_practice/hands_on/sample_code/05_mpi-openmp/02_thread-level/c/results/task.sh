#!/bin/bash
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:03:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM --mpi "max-proc-per-node=48"
#PJM --mpi "rank-map-bychip"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "tl"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s


ulimit -s unlimited

NPROCS=1

# Do not create empty stdout and stderr files.
export PLE_MPI_STD_EMPTYFILE="off"

MPIEXE=$(echo "mpiexec -np ${NPROCS}")
MPIIN=
MPIERR=
EXE=../chk_thd_level


# MPI_THREAD_SINGLE
RTL=0
MPIOUT=$(echo "--std-proc out-${RTL} ")
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} ${EXE} ${RTL}

# MPI_THREAD_FUNNELED
RTL=1
MPIOUT=$(echo "--std-proc out-${RTL} ")
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} ${EXE} ${RTL}

# MPI_THREAD_SERIALIZED
RTL=2
MPIOUT=$(echo "--std-proc out-${RTL} ")
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} ${EXE} ${RTL}

# MPI_THREAD_MULTIPLE
RTL=3
MPIOUT=$(echo "--std-proc out-${RTL} ")
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} ${EXE} ${RTL}
