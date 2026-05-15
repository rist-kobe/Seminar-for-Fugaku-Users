#!/bin/bash
#---Input environment variables
#NTHREADS: Number of threads
#TAFF: Thread affinity



# Executable
BINDIR=../../../00_stream/stream.v5/Obj_f.fj_zfill
EXE=${BINDIR}/stream.exe
LOGFILE=omp${NTHREADS}

# Paging 
#export XOS_MMM_L_HPAGE_TYPE=hugetlbfs #none
export XOS_MMM_L_PAGING_POLICY=demand:demand:prepage 
#export XOS_MMM_L_ARENA_LOCK_TYPE=1 #0

# OpenMP
export OMP_NUM_THREADS=${NTHREADS}
export OMP_STACKSIZE=512M

if [ ${NTHREADS} -eq 1 ] ; then
  export FLIB_CNTL_BARRIER_ERR=FALSE
else
  # Thread affinity and memory bind
  if [ ${TAFF} =  "hbarrier" ] ; then
     export FLIB_BARRIER=HARD
     NMAC=$(echo "numactl --localalloc ")
  elif [ ${TAFF} = "close" ] ; then
     export FLIB_BARRIER=SOFT
     export OMP_PLACES=cores
     export OMP_PROC_BIND=close
     NMAC=$(echo "numactl --localalloc ")
  elif [ ${TAFF} = "spread" ] ; then
     export FLIB_BARRIER=SOFT
     export OMP_PLACES=cores
     export OMP_PROC_BIND=spread
     #NMAC=$(echo "numactl --membind=4,5,6,7 ")
     #NMAC=$(echo "numactl --interleave=all ")
  elif [ ${TAFF} = "customize" ] ; then
     # example of a "scatter" setting for 48 threads
     export FLIB_BARRIER=SOFT
     export GOMP_CPU_AFFINITY="12-48:12 13-49:12 14-50:12 15-51:12 16-52:12 17-53:12 18-54:12 19-55:12 20-56:12 21-57:12 22-58:12 23-59:12"
     #NMAC=$(echo "numactl --membind=4,5,6,7 ")
     #NMAC=$(echo "numactl --interleave=all ")
  else
     # default: equal to "close"
     export FLIB_BARRIER=SOFT
     export OMP_PLACES=cores
     export OMP_PROC_BIND=close
     #export GOMP_CPU_AFFINITY="12 13 14 15 16 17 18 19 20 21 22 23"
     NMAC=$(echo "numactl --localalloc ")
  fi
fi

ulimit -s unlimited
${NMAC} ${EXE} > ${LOGFILE}
