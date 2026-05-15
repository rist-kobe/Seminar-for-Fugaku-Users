#!/bin/bash
PERF=fapppx
#PERF=fapp

${PERF} -A -d fappd1 -Icpupa,nompi -o pa1.csv -tcsv
${PERF} -A -d fappd2 -Icpupa,nompi -o pa2.csv -tcsv
${PERF} -A -d fappd3 -Icpupa,nompi -o pa3.csv -tcsv
${PERF} -A -d fappd4 -Icpupa,nompi -o pa4.csv -tcsv
${PERF} -A -d fappd5 -Icpupa,nompi -o pa5.csv -tcsv
