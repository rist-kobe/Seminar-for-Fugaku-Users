#!/bin/bash
# See https://access.redhat.com/discussions/4780341
## for cross compiling
RPC_INC_DIR=/opt/FJSVxos/devkit/aarch64/rfs/usr/include/tirpc
RPC_LIB_DIR=/opt/FJSVxos/devkit/aarch64/rfs/usr/lib64

export fcc_env=-Nclang
export FCC_env=-Nclang
export CFLAGS="-Nclang -v -O2 -I${RPC_INC_DIR}"
export LD_LIBRARY_PATH=${FJSVXTCLANGA}/lib64:${RPC_LIB_DIR}:${LD_LIBRARY_PATH}
export LDLIBS="-ltirpc" # See scripts/build

# CC and OS must be passed as make variable, rather than env variables.
make CC="fccpx" OS="aarch64-linux-gnu" lmbench
