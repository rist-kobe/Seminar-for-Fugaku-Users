#!/bin/bash 
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=2"
#PJM --rsc-list "elapse=00:03:00"
#PJM --rsc-list "node-mem=23Gi"
#PJM --mpi "max-proc-per-node=4"
#---#PJM --mpi "rank-map-bychip"
#---#PJM --mpi "rank-map-bynode"
#---#PJM --mpi "rank-map-hostfile"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "rmap"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s


ulimit -s unlimited

# OMP
#NTHREADS=12
#export OMP_NUM_THREADS=${NTHREADS}
unset OMP_NUM_THREADS
export OMP_STACKSIZE=1G
export FLIB_BARRIER=SOFT #HARD
export OMP_PLACES=cores
export OMP_PROC_BIND=close
#export OMP_DISPLAY_ENV=TRUE
#export OMP_DISPLAY_AFFINITY=TRUE
#export OMP_AFFINITY_FORMAT="thread: %5n   affinity: %5A "
#export GOMP_CPU_AFFINITY  #LLVM or GNU

# MPI (MCA param)
#ND=2
#PPN=4
#NPROCS=$((ND*PPN))

NPROCS=$(awk 'END{print NR}' vcoord)

#export OMPI_MCA_plm_ple_memory_allocation_policy=localalloc 
#export OMPI_MCA_plm_ple_numanode_assign_policy=share_cyclic 
export OMPI_MCA_mpi_print_stats=1 #2

# Do not create empty stdout and stderr files.
export PLE_MPI_STD_EMPTYFILE="off"

# Executable file 
EXE=../../run.x

# Execution
MPIEXE=$(echo "mpiexec -np ${NPROCS} ")
MPIIN=$(echo "--vcoordfile vcoord")
MPIOUT=$(echo "--stdout-proc output ")
MPIERR=$(echo "--stderr-proc logerr ")

${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} bash run.sh ${EXE}
