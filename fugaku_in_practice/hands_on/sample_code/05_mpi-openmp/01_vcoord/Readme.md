### 05_mpi-openmp/01_vcoord
# Hands-on: Rank allocation with vcoordfile in Fujitsu MPI
* Choose either C/C++ (`c`) or Fortran (`fortran`) samples. Both of them are fine, as well.


## C/C++
### How to compile and how to execute
#### 1. Compile program
* The executable file (`run.x`) is generated in `c/`.
```
$ cd c
$ make  # make -f Makefile.own # if using own compiler
$ ls
run.x ...
```

#### 2. Run program
* We have two settings of jobs; `results/default` and `results/vcoord`.
  * `default`: Standard rank allocation using the job scheduler. Number of nodes = 2, Process-per-node=4, Number of threads=12
  * `vcoord` : Rank allocation using vcoordfile (`vcoord`). Number of nodes = 2. Other settings are controlled by `vcoord`.
* You can run the program either:
```
## To run as a batch job
$ cd c/results/default
$ pjsub task.sh 
## Or, to run in an interactive job
$ cd c/results/default
$ bash task.sh  
```
* The jobs in the Exercises will be completed within 1 minutes. 
  * For safety, we set the elapsed time of the job scripts as 3 minutes.

### Exercises A
* E1: Check the rank allocation in `results/default`, using the job statistical information file (`*.stats`) and the standard output/error files. 
* E2: Check the vcoordfile (`vcoord`) in `results/vcoord`. How many MPI tasks  are allocated in each of nodes? What about the number of OpenMP threads per MPI task?
* E3: Check the rank allocation in `results/vcoord`. 


## Fortran
### How to compile and how to execute
#### 1. Compile program
* The executable file (`run.x`) is generated in `fortran/`.
```
$ cd fortran
$ make  # make -f Makefile.own # if using own compiler
$ ls
run.x ...
```

#### 2. Run program
* We have two settings of jobs; `results/default` and `results/vcoord`.
  * `default`: Standard rank allocation using the job scheduler. Number of nodes = 2, Process-per-node=4, Number of threads=12
  * `vcoord` : Rank allocation using vcoordfile (`vcoord`). Number of nodes = 2. Other settings are controlled by `vcoord`.

* You can run the program either:
```
## To run as a batch job
$ cd fortran/results/default
$ pjsub task.sh 
## Or, to run in an interactive job
$ cd fortran/results/default
$ bash task.sh  
```
* The jobs in the Exercises will be completed within 1 minutes. 
  * For safety, we set the elapsed time of the job scripts as 3 minutes.

### Exercises A
* E1: Check the rank allocation in `results/default`, using the job statistical information file (`*.stats`) and the standard output/error files. 
* E2: Check the vcoordfile (`vcoord`) in `results/vcoord`. How many MPI tasks  are allocated in each of nodes? What about the number of OpenMP threads per MPI task?
* E3: Check the rank allocation in `results/vcoord`. 