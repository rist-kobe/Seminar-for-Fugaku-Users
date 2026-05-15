#!/bin/bash
# Copyright 2024 Research Organization for Information Science and Technology
function projlst () {
cat << EOF
Obj_clang
Obj_clang.512.swp
Obj_clang.inlv2
Obj_clang.novec
#Obj_trad.swp
EOF
}

INP=logfile
OUTPUT=stat.csv
SRCD=..
SUBDIR=results

{
echo "BN,FMA,ELP_sec,Gflops"

for pl in `projlst` ; do
  if echo ${pl} |grep -E -s -q "^#"; then
     continue
  fi 
  fn=${SRCD}/${pl}/${SUBDIR}/${INP}
  if [ ! -f ${fn} ] ; then
     continue 
  fi
  
  bn=$(echo ${pl}|sed -e 's|Obj_||g')

  lnum=$(grep -E -I -n "1 FMA" ${fn}|sed -e 's|:.*$||g')
  elp=$(sed -n $((lnum+4)),$((lnum+4))p ${fn} |sed -e 's|^.*:||g'|sed -E 's| +||g')
  gflops=$(sed -n $((lnum+5)),$((lnum+5))p ${fn} |sed -e 's|^.*:||g'|sed -E 's| +||g')
  echo "${bn},1,${elp},${gflops}"

  lnum=$(grep -E -I -n "4 FMA" ${fn}|sed -e 's|:.*$||g')
  elp=$(sed -n $((lnum+4)),$((lnum+4))p ${fn} |sed -e 's|^.*:||g'|sed -E 's| +||g')
  gflops=$(sed -n $((lnum+5)),$((lnum+5))p ${fn} |sed -e 's|^.*:||g'|sed -E 's| +||g')
  echo "${bn},4,${elp},${gflops}"

  lnum=$(grep -E -I -n "8 FMA" ${fn}|sed -e 's|:.*$||g')
  elp=$(sed -n $((lnum+4)),$((lnum+4))p ${fn} |sed -e 's|^.*:||g'|sed -E 's| +||g')
  gflops=$(sed -n $((lnum+5)),$((lnum+5))p ${fn} |sed -e 's|^.*:||g'|sed -E 's| +||g')
  echo "${bn},8,${elp},${gflops}"

  lnum=$(grep -E -I -n "16 FMA" ${fn}|sed -e 's|:.*$||g')
  elp=$(sed -n $((lnum+4)),$((lnum+4))p ${fn} |sed -e 's|^.*:||g'|sed -E 's| +||g')
  gflops=$(sed -n $((lnum+5)),$((lnum+5))p ${fn} |sed -e 's|^.*:||g'|sed -E 's| +||g')
  echo "${bn},16,${elp},${gflops}"
done
} > ${OUTPUT}
