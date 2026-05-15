#!/bin/bash
# Copyright 2024 Research Organization for Information Science and Technology
function nslst () {
cat <<EOF
20
40
80
100
200
400
600
800
1000
1200
1400
EOF
}

OUTPUT=out.csv
PREFIX=../Obj_fj-ssl2/results/outfile
iheader=0
{
for i in $(nslst); do
  if echo ${i} |grep -s -q -E "^#" ; then
     continue
  fi

  nline=$(awk 'END{print NR}' ${PREFIX}.${i})

  if [ ${iheader} -eq 0 ] ; then
    sed -n 1,1p ${PREFIX}.${i} |sed -E "s/ +/,/g" |sed -e "s/^,//g" |sed -e "s/,$//g"
    sed -n 2,${nline}p ${PREFIX}.${i} |sed -E "s/ +/,/g" |sed -e "s/^,//g" |sed -e "s/,$//g"
    iheader=1
  else
    sed -n 2,${nline}p ${PREFIX}.${i} |sed -E "s/ +/,/g" |sed -e "s/^,//g" |sed -e "s/,$//g"
  fi

done
} > ${OUTPUT}
