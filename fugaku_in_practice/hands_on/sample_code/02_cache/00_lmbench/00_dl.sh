#!/bin/bash
#wget  --content-disposition https://sourceforge.net/projects/lmbench/files/latest/download
wget --no-check-certificate --content-disposition https://sourceforge.net/projects/lmbench/files/latest/download
find . -name "*?viasf=1" -print0 |xargs -0 rename --verbose "?viasf=1" ""

#git clone https://github.com/intel/lmbench.git
