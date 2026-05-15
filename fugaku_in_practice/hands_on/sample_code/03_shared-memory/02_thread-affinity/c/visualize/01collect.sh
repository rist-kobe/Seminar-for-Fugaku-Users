#!/bin/bash
# Copyright 2024 Research Organization for Information Science and Technology 
function pjlst () {
cat <<EOF
fj_zfill.close
fj_zfill.spread
EOF
}

function ntlst () {
cat <<EOF
1
#2
4
8
12
24
#32
48
EOF
}

TAGD=..

######################################################
for pl in $(pjlst); do
######################################################
if echo ${nt} |grep -E -q -s "^#" ; then
   continue
fi

OUTPUT=stat.${pl}.csv
iheader=0
{
for nt in $(ntlst) ; do
  if echo ${nt} |grep -E -q -s "^#" ; then
     continue
  fi
  nnt=$(echo ${nt} |awk '{printf"%02d", $1}') 
  fname=${TAGD}/${pl}/omp${nt}

  if [ ${iheader} -eq 0 ] ; then
     printf "BN,"
     printf "NT,"
     grep -E "Function.*" ${fname} |sed -e 's/://g' \
        |sed -e 's/Best Rate MB\/s/Rate_MB\/s/g' \
        |sed -e 's/ (MB\/s)/_MB\/s/g' \
        |sed -e 's/ time/_time/g' |sed -E 's/ +/,/g'
  iheader=1
  fi

  printf "%s," ${pl}
  printf "%d," ${nt}
  grep -E "Copy.*" ${fname} |sed -e 's/://g' |sed -E 's/ +/,/g'

  printf "%s," ${pl}
  printf "%d," ${nt}
  grep -E "Scale.*" ${fname} |sed -e 's/://g' |sed -E 's/ +/,/g'

  printf "%s," ${pl}
  printf "%d," ${nt}
  grep -E "Add.*" ${fname} |sed -e 's/://g' |sed -E 's/ +/,/g'

  printf "%s," ${pl}
  printf "%d," ${nt}
  grep -E "Triad.*" ${fname} |sed -e 's/://g' |sed -E 's/ +/,/g'

done
} > ${OUTPUT}
######################################################
done
######################################################
