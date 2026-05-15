#!/bin/bash 
#PJM --gname [project name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=2,elapse=00:06:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM --mpi "proc=2"
#PJM --mpi "max-proc-per-node=1"
#---#PJM --mpi "rank-map-bychip"
#PJM --mpi "rank-map-bynode"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "imb"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s


ulimit -s unlimited

# MPI
ND=1
PPN=2
NPROCS=$((ND*PPN))

# Do not create empty stdout and stderr files.
export PLE_MPI_STD_EMPTYFILE="off"

# Common setting of MCA parameters
#export OMPI_MCA_plm_ple_memory_allocation_policy=localalloc 
#export OMPI_MCA_plm_ple_numanode_assign_policy=share_cyclic 
export OMPI_MCA_mpi_print_stats=1 #2

# Executable file 
BINDIR=../../00_imb/IMB-v2021.3
EXE=${BINDIR}/IMB-MPI1

# Executions (3 ways)
ulimit -s unlimited

## 1. Pingpong 
MPIEXE=$(echo "mpiexec -np ${NPROCS} ")
MPIIN=
MPIOUT=$(echo "--stdout-proc out ")
MPIERR=$(echo "--stderr-proc err ")
# LLC(L2)=32MiB, Cache Line=256 bytes
CMDOPT=$(echo "-thread_level single -npmin ${NPROCS} -off_cache 32,256 ") 

${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} \
${EXE} ${CMDOPT} PingPong 


# 2. Pingpong with short message
MPIEXE=$(echo "mpiexec -np ${NPROCS} ")
MPIIN=
MPIOUT=$(echo "--stdout-proc out-short ")
MPIERR=$(echo "--stderr-proc err-short ")
# LLC(L2)=32MiB, Cache Line=256 bytes
CMDOPT=$(echo "-thread_level single -npmin ${NPROCS} -off_cache 32,256 -msglen msg.txt ")

${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} \
${EXE} ${CMDOPT} PingPong 


# 3. Pingpong in (almost) Rendezvous communication mode
MPIEXE=$(echo "mpiexec -np ${NPROCS} ")
MPIIN=
MPIOUT=$(echo "--stdout-proc out-rendezvous ")
MPIERR=$(echo "--stderr-proc err-rendezvous ")
# LLC(L2)=32MiB, Cache Line=256 bytes
CMDOPT=$(echo "-thread_level single -npmin ${NPROCS} -off_cache 32,256 ")

export OMPI_MCA_btl_tofu_eager_limit=256

${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} \
${EXE} ${CMDOPT} PingPong
