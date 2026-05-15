#!/bin/bash
# List of settings
# If sepecifying "#" in front of the label, the corresponding setting is skipped.
function objlst () {
cat <<EOF
clang
#clang.512
clang.512.swp
clang.inlv2
clang.novec
#trad
#trad.nosimd
#trad.swp
EOF
}

PREFIX="Obj_"
MAKE_DIR="config"  #for cross compiler
#MAKE_DIR="config.own"  #for own compiler
#MAKE_DIR="config.intel"

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
