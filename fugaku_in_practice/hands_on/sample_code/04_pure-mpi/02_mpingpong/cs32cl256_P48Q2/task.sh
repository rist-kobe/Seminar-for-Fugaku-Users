#!/bin/bash
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=2,elapse=00:04:00"
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

# Do not create empty stdout and stderr files.
export PLE_MPI_STD_EMPTYFILE="off"

# MPI 
#export OMPI_MCA_plm_ple_memory_allocation_policy=localalloc
#export OMPI_MCA_plm_ple_numanode_assign_policy=share_cyclic 
export OMPI_MCA_mpi_print_stats=1 #2

# Executable file 
BINDIR=../../00_imb/IMB-v2021.3
EXE=${BINDIR}/IMB-MPI1

# Execution
MPIEXE=$(echo "mpiexec ")
MPIIN=
MPIOUT=$(echo "--stdout-proc out ")
MPIERR=$(echo "--stderr-proc err ")
# map setting: ex. If N nodes of X processors, P=X and Q=N
# -multi 0 means to show lowest performance.
NP=48
NQ=2
CMDOPT=$(echo "-thread_level single -npmin ${NP} -multi 0 -off_cache 32,256 -map ${NP}x${NQ}")

${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} \
${EXE} ${CMDOPT} PingPong
