### 03_shared-memory/00_stream
# Hands-on: Building STREAM benchmark
## 0. Legend
* `[src_dir]` : source directory
* `[rist_dir]`: this directory


## 1. Get source file
```
$ bash 00_dl.sh
$ ls
stream.v5  # The directory name is specified in 00_dl.sh. In this case, [src_dir] is stream.v5.
```


## 2. Preparation
```
$ cd [src_dir]
$ cp [rist_dir]/rist/Makefile.fj .
$ cp [rist_dir]/rist/Makefile.fj_zfill .
```

* We recommend that you modify the source code to properly show the results. See `[rist_dir]/rist/patch.rist`.  We show a way of applying the patch file here.
```
$ patch -p 1 -d [src_dir] < [rist_dir]/rist/patch.rist
patching file stream.c
patching file stream.f
```

## 3. Set array size
* STREAM is a benchmark to measure memory bandwidth (memory access throughput, bytes/sec). 
* Therefore, the memory size for the arrays needs to be larger than the size of the Last-level cache (LLC) in your machine.
* Set the array size in the following manner. Recall that the LLC of A64FX is L2 and its size is 4x8(=32)MiB.
  * As for FORTRAN (stream.f): Edit `PARAMETER n` in stream.f.
  * As for C (stream.c): Edit `STREAM_ARRAY_SIZE` in stream.c. Or, set `-DSTREAM_ARRAY_SIZE` in makefile.


## 4. Compile
* You can find the executable file in each of `Obj_***` directories. 
* If you want to use own compiler, use `Makefile.fj_zill.own` and so on.
  * If you set a quite large array size, compiling would be failed. In this case, add `-mcmodel=large` to the compiler option. 
* Compare the compiler options (`CFLAGS` and `FFLAGS`) of `Makefile.fj` to those of `Makefile.fj_zfill`. 
```
$ cd [src_dir]
# We show the case when one choose Makefile.fj_zfill, for example:
$ make -f Makefile.fj_zfill &> make.fj_zfill.log
$ ls 
Obj_c.fj_zfill  Obj_ctrad.fj_zfill  Obj_f.fj_zfill  
```

### Note
* We summarize the main compiler options of each Makefile.
```
Makefile.fj            #Optimization level is fast. Auto-vectorization is allowed. OpenMP thread is allowed. 
Makefile.fj_zfill      #Optimization level is fast. Auto-vectorization is allowed. OpenMP thread is allowed. ZFILL option is set.
```
