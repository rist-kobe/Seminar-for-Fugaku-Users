#!/bin/bash
# List of settings
# If sepecifying "#" in front of the label, the corresponding setting is skipped.
function objlst () {
cat <<EOF
#nosimd
#simd
swp
EOF
}

PREFIX="Obj_"
MAKE_DIR="config"
MAKE_DIR="config"  #for cross compiler
#MAKE_DIR="config.own"  #for own compiler

for ol in `objlst`; do
  if echo ${ol} |grep -E -s -q "^#"; then
    continue
  fi
  dirname=${PREFIX}${ol}
  fname="Makefile.${ol}"
  mkdir -p ${dirname}/results

  cp -v *.f90 ${dirname}/
  cp -v task.sh ${dirname}/results
  cd ${dirname}
  make -f ../${MAKE_DIR}/${fname} &> make.log
  rm *.f90
  cd ..
done
