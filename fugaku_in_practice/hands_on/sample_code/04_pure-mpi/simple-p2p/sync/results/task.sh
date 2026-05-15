#!/bin/bash
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=2,elapse=00:06:00"
#PJM --mpi "proc=2"
#PJM --mpi "max-proc-per-node=1"
#---#PJM --mpi "rank-map-bychip"
#PJM --mpi "rank-map-bynode"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "p2p"
#PJM -o "%n.%j.out"
#PJM -e "%n.%j.err"
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
EXE=../run.x

mpiexec -np ${NPROCS} --stdout-proc out --stderr-proc err ${EXE} 
