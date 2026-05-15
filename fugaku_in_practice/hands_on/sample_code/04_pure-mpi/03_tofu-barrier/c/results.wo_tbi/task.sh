#!/bin/bash
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
# #PJM -L "node=12,elapse=00:04:00"
#PJM -L "node=12:torus,elapse=00:04:00"
#PJM --mpi "max-proc-per-node=4" 
#PJM --mpi "rank-map-bychip"
#PJM -x PJM_LLIO_GFSCACHE=/vol0006
#PJM -N "tbi"
#PJM -o  "%n.%j.out"
#PJM -e  "%n.%j.err"
#PJM -s

ND=12
PPN=4
NP=$((ND*PPN))

# Do not create empty stdout and stderr files.
export PLE_MPI_STD_EMPTYFILE="off"

export OMPI_MCA_plm_ple_memory_allocation_policy=localalloc # default
export OMPI_MCA_plm_ple_numanode_assign_policy=share_cyclic # default
export OMPI_MCA_mpi_print_stats=2  #1
export OMPI_MCA_mpi_print_stats_ranks=0,1 # effective only if mpi_print_stats=2 or 4
export OMPI_MCA_coll=^tbi
#export OMPI_MCA_coll_tbi_intra_node_reduction=3 #default
#export OMPI_MCA_coll_base_reduce_commute_safe=0 #default

ulimit -s unlimited

EXE=../elm3/run.x
MPIEXE=$(echo "mpiexec -np ${NP} ")
MPIIN=
MPIOUT=$(echo "-stdout-proc out ") 
MPIERR=$(echo "-stderr-proc err ")
${MPIEXE} ${MPIIN} ${MPIOUT} ${MPIERR} ${EXE}
