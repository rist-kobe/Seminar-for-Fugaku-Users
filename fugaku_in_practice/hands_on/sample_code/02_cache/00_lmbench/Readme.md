### 02_cache/00_lmbench
# Hands-on: Building LMbench
## 0. Legend
* `[src_dir]` : directory of source 
* `[rist_dir]`: this directory 

## 1. Get source files
```
$ cd [rist_dir]
$ bash 00_dl.sh
$ ls
lmbench-3.0-a9.tgz 
$ tar -xzvf lmbench-3.0-a9.tgz
```

## 2. Preparation 
### 2.1 Edit build script
* One needs to modify `LDLIBS` in `[src_dir]/scripts/build`, such as `LDLIBS="${LDLIBS} -lm"`.  
* We note that `${LDLIBS}` is set in `[rist_dir]/01_build.sh`. 
```
$ cd [src_dir]/scripts
$ ls build
build 
$ cp build build.orig # back-up
# Launch any editors, such as vi.
$ vi build
# Please check LDLIBS variable in build and properly modify it. 
...
#LDLIBS=-lm            # Original 
LDLIBS="${LDLIBS} -lm" # Modified 
...
```

### 2.2 Edit Makefile
* One needs to change `CFLAGS` for rule `lmbench` in `[src_dir]/src/Makefile` from `-O` to the environment variable, such as `CFLAGS="$(CFLAGS)"`.  
* We note that `$(CFLAGS)` is set in `[rist_dir]/01_build.sh`.
```
$ cd [src_dir]/src
$ ls Makefile
Makefile
$ cp Makefile Makefile.orig # back-up
# Launch any editors, such as vi.
$ vi build
# Please check CFLAGS for lmbench and properly modify it.
...
lmbench: $(UTILS)
#        @env CFLAGS=-O (...) all # Original
#        -@env CFLAGS=-O (...) opt # Original
        @env CFLAGS="$(CFLAGS)" (...) all # Modified
        -@env CFLAGS="$(CFLAGS)" (...) opt # Modified
...
```

## 3. Compile
* Check script `01_build.sh` to compile LMbench.
* The benchmark programs may be installed in `[src_dir]/bin/aarch64-linux-gnu` if everything is successful.
```
$ cd [src_dir]/src
$ cp [rist_dir]/01_build.sh .
$ bash 01_build.sh &> 01_build.log  # < 2 min.
```
