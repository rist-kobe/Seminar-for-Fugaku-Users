### 04_pure-mpi/02_mpingpong
# Hands-on: IMB: Multiple Pingpong (Send and Recv) 
* Both of C/C++ and Fortran users will perform the common benchmarks, although IMB is written by C and C++.


## How to execute
### 1. Edit a job script
* Before trying this hands-on, you need to do `00_imb` to compile Intel MPI benchmark.
* We have two working directories, `cs32cl256_P48Q2` and `cs32cl256_P4Q2`.
* A job script to execute the program is `task.sh`  in each of working directories. 
* Edit `BINDIR` variable in `task.sh`. You need to write your installed location of IMB binary (e.g., `IMB-MPI1`) there.

### 2. Run program
* You can run the program either:
```
## To run as a batch job
$ cd cs32cl256_P48Q2
$ pjsub task.sh 
## Or, to run in an interactive job
$ cd cs32cl256_P48Q2
$ bash task.sh 
```
* The jobs in the Exercises will be completed within 1-2 minutes. 
  * For safety, we set the elapsed time of the job scripts as 4 minutes.

### Exercises A
* E1: Check the node and MPI settings in `cs32cl256_P48Q2/task.sh` and `cs32cl256_P4Q2/task.sh`. What kinds of differences are there?
  * P48Q2: 2 nodes, 48 processes per node.
  * P4Q2 : 2 nodes, 4 processes per node. Four is equivalent to the number of CMG per node.
* E2: Compare the measured bandwidth between the two settings (i.e., `P48Q2` and `P4Q2`).

### Exercises B (advanced)
* E3: Confirm whether MPI communication between non-neighboring nodes occurs or not, using the MPI statistical information. 