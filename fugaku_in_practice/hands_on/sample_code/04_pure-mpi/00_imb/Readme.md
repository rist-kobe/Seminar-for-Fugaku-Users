### 04_pure-mpi/00_imb
# Hands-on: Building Intel MPI Benchmark
## 0. Legend
* `[src_dir]` : directory of source 
* `[rist_dir]`: this directory 

## 1. Get source files
```
$ bash 00_dl.sh
$ ls
IMB-v2021.3  ...
```


## 2. Preparation
* Edit Makefile for Fujitsu C/C++ compiler.
  * `CFLAGS += -Nclang -g -O0 -std=gnu11 -Wall -Wno-long-long`
  * `CXXFLAGS += -Nclang -g -O0 -std=gnu++11 -Wall -Wextra -Wpedantic -Wno-long-long`
```
$ cd [src_dir]/src_cpp
$ cp Makefile Makefile_orig
$ vi Makefile # Any editor is acceptable.
```

* Edit `CACHE_SIZE` and `CACHE_LINE_SIZE` in `IMB_mem_info.h` for A64FX. Recall the measured results of LMbench about the size of cache line. 
  * `CACHE_SIZE 32` (Unit is MiB). 
  * `CACHE_LINE_SIZE 256` (Unit is byte).
```
$ cd [src_dir]/src_c
$ cp IMB_mem_info.h IMB_mem_info.h_orig
$ vi IMB_mem_info.h
```


## 3. Compile
```
$ cd [src_dir]
$ cp [rist_dir]/01_build.sh .
$ bash 01_build.sh &> 01_build.log  #< 1 min.
$ ls
IMB-MPI1  ...  
```
* The executable files will be put in `[src_dir]/`