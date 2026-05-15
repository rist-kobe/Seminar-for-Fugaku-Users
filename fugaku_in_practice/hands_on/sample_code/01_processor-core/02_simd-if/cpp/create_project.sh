#!/bin/bash
function objlst () {
cat <<EOF
clang
#clang.512
clang.novec
#trad
#trad.nosimd
#trad.simd2
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
  mkdir -p ${dirname}/results

  cp -v *.cpp ${dirname}/
  cp -v *.h ${dirname}/
  cp -v task.sh ${dirname}/results
  cd ${dirname}
  make -f ../${MAKE_DIR}/${fname} &> make.log
  rm *.cpp
  rm *.h
  cd ..
done
