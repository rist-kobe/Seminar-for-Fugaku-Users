#!/bin/bash
# Copyright 2024 Research Organization for Information Science and Technology 
#### function ####
function getlnum () {
grep -E -i -n "$1" $2|sed -e 's/:.*$//g'
}

function get1stlnum () {
grep -E -i -m 1 -n "$1" $2|sed -e 's/:.*$//g'
}
#### function: End ####

INP=$1

if [ $# -ne 1 ] ; then
cat <<EOF
[usage] convert2csv.sh
        (arg1) input file 
EOF
  exit 0
fi

srdllst=$(getlnum "stride" ${INP})
declare -a srdlarray
id=0
for srd in `echo ${srdllst}`; do
   srdlarray[${id}]=${srd}
   #echo ${srdlarray[id]}
   id=$((id+1))
done
srdlarray[${id}]=$(awk 'END{print NR}' ${INP})
NSRD=$((id))

OUTPUT=$(echo ${INP}|sed -e 's/\.\.\///g'|sed -e 's/MB.*$//g'|sed -e 's/$/MB\.csv/g')

{
echo "#stride,range_MB,nanosec"
for id in `seq 0 $((NSRD-1))`;do
  lsta=${srdlarray[id]}
  srd=$(sed -n ${lsta},${lsta}p ${INP}|sed -e 's/^.*=//g')
  lsta=$((lsta+1))
  lend=${srdlarray[id+1]}
  lend=$((lend-1))
  sed -n ${lsta},${lend}p  ${INP} \
  |sed -e "/^$/d" \
  |sed -e "s/^/${srd} /g" |sed -E "s/ +/,/g" |sed -e 's/^,//g'
done
} > ${OUTPUT}
