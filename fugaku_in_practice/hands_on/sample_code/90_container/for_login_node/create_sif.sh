#!/bin/sh
### for Fugaku login nodes

SIF_FILE=visualize.sif
DEF_FILE=for_python.def
BASE_IMAGE=python:3.13.11-trixie


cat << EOD > $DEF_FILE
Bootstrap: docker
From: $BASE_IMAGE

%post
   python -m pip install --upgrade pip

   pip install pandas==2.3.3
   pip install matplotlib==3.10.8

%test
   echo "======================="
   echo "This image is based $BASE_IMAGE"
   echo ""
   pip list
   echo "======================="
EOD

singularity build --fakeroot $SIF_FILE $DEF_FILE |& tee log.creat_sif
