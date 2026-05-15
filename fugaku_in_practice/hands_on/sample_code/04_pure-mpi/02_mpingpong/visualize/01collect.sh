#!/bin/bash
# Copyright 2024 Research Organization for Information Science and Technology 
##### function #####
function pjlst () {
cat <<EOF
cs32cl256_P48Q2
cs32cl256_P4Q2
EOF
}

function getlnum () {
grep -E -n "$1" $2 |sed -e 's/:.*$//g'
}

function get1stlnum () {
grep -E -n -m 1 "$1" $2 |sed -e 's/:.*$//g'
}
##### function: End #####

SRCD=..
######################################################
for pl in $(pjlst) ; do
######################################################

INP="${SRCD}/${pl}/out.1.0"
OUTPUT="out.${pl}.csv"

#LNLST=$(getlnum "# #processes" ${INP})
LNLST=$(getlnum "#.*groups of.*processes" ${INP})

{
icnt=0
for ll in `echo ${LNLST}`;do 
  if [ ${icnt} -gt 0 ] ; then
     break
  fi
  lsta=$(tail -n +${ll} ${INP} |get1stlnum ".*#repetitions")
  lsta=$((lsta+ll-1))
  sed -n ${lsta},${lsta}p ${INP}  \
  |sed -e "s/^/np ngrp/g" \
  |sed -E 's/ +/,/g' |sed -e "s/^,//g" |sed -e "s/#//g"
  icnt=1
done

for ll in `echo ${LNLST}`;do 
  np=$(sed -n ${ll},${ll}p ${INP} |sed -e "s/.*groups of //g" |sed -e "s/ processes.*//g")
  ngrp=$(sed -n ${ll},${ll}p ${INP} |sed -e "s/ groups of.*processes.*//g" |sed -e "s/# ( //g")
  lsta=$(tail -n +${ll} ${INP} |get1stlnum ".*#repetitions")
  lsta=$((lsta+ll))
  lend=$(tail -n +${lsta} ${INP} |get1stlnum "^#.*")
  lend=$((lend-2+lsta))
  sed -n ${lsta},${lend}p ${INP} \
  |sed -e '/^$/d' \
  |sed -e "s/^/${np} ${ngrp}/g" \
  |sed -E 's/ +/,/g' |sed -e "s/^,//g"
done
} > ${OUTPUT}

######################################################
done
######################################################
