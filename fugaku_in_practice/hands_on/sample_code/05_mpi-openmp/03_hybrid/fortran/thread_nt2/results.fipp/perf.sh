#!/bin/bash
SRCDRIR= 
PERFDIR=$(echo "fippd")
OUTPUT="cost.txt"
PERF=fipppx #fipp
PERFOPT=$(echo "-A -Icall,cpupa,nobalance,mpi,src${SRCDIR} -Tall -btotal -pinput=0,limit=0 -l0 -o ${OUTPUT} -ttext -d ${PERFDIR} ")

${PERF} ${PERFOPT} 
