#!/bin/bash
PERF=fapppx
#PERF=fapp
PERFD=fappd
PERFOPT=$(echo "-A -Icpupa,mpi -o cost.txt -p0,input=0,limit=0 -ttext -d ${PERFD}")

${PERF} ${PERFOPT} 
