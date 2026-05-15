#!/bin/bash 
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1,elapse=00:03:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM --mpi "max-proc-per-node=48"
#PJM --mpi "rank-map-bychip"
#---#PJM --mpi "rank-map-bynode"
#---#PJM --mpi "rank-map-hostfile"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "imb"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s


ulimit -s unlimited

NPROCS=2

# Do not create empty stdout and stderr files.
export PLE_MPI_STD_EMPTYFILE="off"

#EXE=[src_dir]/IMB-MPI1 #[src_dir] is your installed location of Intel MPI benchmark
EXE=../../../04_pure-mpi/00_imb/IMB-v2021.3/IMB-MPI1

echo "single: Use MPI_Init"
MPIEXE=$(echo "mpiexec -np ${NPROCS} ")
MPIIN=
MPIOUT=$(echo "--stdout-proc mpi1-0.out ")
MPIERR=$(echo "--stderr-proc mpi1-0.err ")
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} ${EXE} -thread_level single PingPong

echo "funneled: Use MPI_Init_thread"
MPIEXE=$(echo "mpiexec -np ${NPROCS} ")
MPIIN=
MPIOUT=$(echo "--stdout-proc mpi1-1.out ")
MPIERR=$(echo "--stderr-proc mpi1-1.err ")
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} ${EXE} -thread_level funneled PingPong

echo "serialized: Use MPI_Init_thread"
MPIEXE=$(echo "mpiexec -np ${NPROCS} ")
MPIIN=
MPIOUT=$(echo "--stdout-proc mpi1-2.out ")
MPIERR=$(echo "--stderr-proc mpi1-2.err ")
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} ${EXE} -thread_level serialized PingPong

echo "multiple: Use MPI_Init_thread"
MPIEXE=$(echo "mpiexec -np ${NPROCS} ")
MPIIN=
MPIOUT=$(echo "--stdout-proc mpi1-3.out ")
MPIERR=$(echo "--stderr-proc mpi1-3.err ")
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} ${EXE} -thread_level multiple PingPong
