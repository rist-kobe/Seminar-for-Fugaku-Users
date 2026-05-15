### 06_llio/02_sharedtmp
# Hands-on: File output using Shared Temporary Region
* Choose either C++ (`cpp`) or Fortran (`fortran`) sample. Both of the are fine, as well.
* In this hands-on, we use Shared Temporary Area.
When we run the scripts in an interactive job, we need to specify `--llio sharedtmp-size=10Gi` option of pjsub option in submitting the interactive job.
* In addition, when we use spack and sort_libp, we need to specify `-x PJM_LLIO_GFSCACHE=/vol0004` in submitting the interactive job.
```
## example:
$ pjsub --interact -g [group_id] -L "node=4, elapse=6:00:00" --sparam "wait-time=unlimited" --llio sharedtmp-size=10Gi -x PJM_LLIO_GFSCACHE=/vol0004 --mpi max-proc-per-node=1
```
## C++
### How to compile and how to execute
#### 1. Compile a program.
* The executable file (`run.x`) is generated in `cpp/`.

```
$ cd cpp
$ make   # make -f Makefile.own  # if using own compiler
$ ls
main.cpp main.lst main.o run.x
```

## Fortran
### How to compile and how to execute
#### 1. Compile a program.
* The executable file (`run.x`) is generated in `fortran/`.

```
$ cd fortran
$ make   # make -f Makefile.own  # if using own compiler
$ ls
main.f90 main.lst main.o run.x
```

#### 2. Run Program
* There are two directories: `SharedTmp` and `2ndLayerCache`.
  *  `SharedTmp`:  The directory is for tasks in which files are output to Shared Temporary Area.
   * `2ndLayerCache`: The directory is for tasks in which files are output to 2nd Layer Storage (FEFS) via Cache Area for 2nd Layer Storage.
```
## To run as a batch job
$ cd ShardTmp
$ pjsub task.sh
$ cd 2ndLayerCache
$ pjsub task.sh
## or , to run in an interactive job
$ cd ShardTmp
$ bash task.sh
$ cd 2ndLayerCache
$ bash task.sh
```

* The array size to be output, the number of calculatipon steps, the frequency of file output, and the output file name are specified in `input.txt`.
* CAUTION: When you run the script, large-size files may be output in your data area of 2nd Layer Storage.
For example, when the array size is 52428800, the size of output file is 4.8 GiB if you run the job using 12 MPI processes.


### Exersises A
* E1: Check the jobscript `SharedTmp/task.sh`, where the path of the Shared Tomporary Area is given by the environmental variable `$PJM_SHAREDTMP` 
and the size of the area we use in this job is specified by the pjsub option `--llio sharedtmp-size`.
* E2: Run the jobscripts in `SharedTmp` and `_2ndLayerCache`, and compare the times taken to file output by checking the standard output file (`result/(jobid).log.1.0`)

### Exersises B (optional)
* E3: Using darshan-parser, check the input and output files in this program and examine the times taken to I/O of each file.
* E4: examine the change of the time taken to file output when you change the number of nodes to 1, 4, 12, 48 and so on.
* E5: examine the change of the time taken to file output when you change the array size to 1024, 65536, 786432, 16777216, 52528800 and so on.
