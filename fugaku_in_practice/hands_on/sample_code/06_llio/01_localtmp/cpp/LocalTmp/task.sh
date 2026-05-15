#!/bin/sh
#PJM --gname [project_name]
# #PJM --rsc-list "rscgrp=small"
#PJM --rsc-list "node=1"
#PJM --rsc-list "elapse=00:08:00"
#PJM --rsc-list "freq=2200, eco_state=2"
#PJM -x PJM_LLIO_GFSCACHE=/vol0004:/vol0006
#PJM --mpi "max-proc-per-node=4"
#PJM --llio localtmp-size=5Gi
# #PJM --llio perf
#PJM -j
#PJM -s
#PJM --name LocalTmp


### setting for darshan
source /vol0004/apps/oss/spack-v1.0.1/share/spack/setup-env.sh
spack load darshan-runtime@3.4.0 scheduler=fj
export DARSHAN_LOG_DIR_PATH=./darshan_output

if [ ! -d $DARSHAN_LOG_DIR_PATH ]; then
   mkdir -p $DARSHAN_LOG_DIR_PATH
fi

export LD_LIBRARY_PATH=`/vol0004/system/tool/sort_libp`
/vol0004/system/tool/sort_libp -s -a


### setting for the program
bindir=../
INPUT=input.txt
OUTPUT=./output
if [ ! -d $OUTPUT ]; then
   mkdir -p $OUTPUT
fi

ARRAY_SIZE=2621440
NLOOP=100
ISKIP=5
cat << EOD > ${INPUT}
${ARRAY_SIZE}
${NLOOP}
${ISKIP}
${PJM_LOCALTMP}/output.txt
EOD

### runing the program
mpiexec -np ${PJM_MPI_PROC} -std-proc ./result/%J.log -x LD_PRELOAD=libdarshan.so ${bindir}/run.x input.txt

## if you do not want a darshan profile
# mpiexec -np ${PJM_MPI_PROC} -std-proc ./result/%J.log ${bindir}/run.x input.txt


### when you want to move the data on the LocalTmp region, uncommend the following lines.
# mpiexec -np ${PJM_MPI_PROC} -std-proc log sh -c \
#   'if [ ${PLE_RANK_ON_NODE} -eq 0 ]; then \
#      mv ${PJM_LOCALTMP}/output.txt_* ${PJM_O_WORKDIR}/${OUTPUT} ; \
#    fi'

