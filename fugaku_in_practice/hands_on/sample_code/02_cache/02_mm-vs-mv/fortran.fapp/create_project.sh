#!/bin/bash
function objlst () {
cat <<EOF
fj-ssl2
#fj-ssl2.fast
#fj-ssl2.fast.matmul
#fj-ssl2.matmul
#fj-ssl2so
EOF
}

PREFIX="Obj_"
MAKE_DIR="config"
#MAKE_DIR="config.own"

for ol in `objlst`; do
  if echo ${ol} |grep -E -s -q "^#"; then
    continue
  fi
  dirname=${PREFIX}${ol}
  fname="Makefile.${ol}"
  mkdir -p ${dirname}/results.Bpa

  cp -v *.F90 ${dirname}/
  cp -v *.c ${dirname}/
  cp -v *.h ${dirname}/
  cp -v task-Bpa.sh ${dirname}/results.Bpa
  cp -v perf-Bpa.sh ${dirname}/results.Bpa
  cd ${dirname}
  make -f ../${MAKE_DIR}/${fname} &> make.log
  rm *.F90
  rm *.c
  rm *.h
  cd ..
done
