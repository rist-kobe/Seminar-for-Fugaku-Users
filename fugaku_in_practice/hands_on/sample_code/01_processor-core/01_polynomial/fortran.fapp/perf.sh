#!/bin/bash
PERF=fapppx
#PERF=fapp
PERFD=fappd
PERFOPT=$(echo "-A -Icpupa,nompi -o cost.txt -ttext -d ${PERFD}")

${PERF} ${PERFOPT} 
