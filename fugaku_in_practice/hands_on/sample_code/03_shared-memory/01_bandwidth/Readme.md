### 03_shared-memory/01_bandwidth
# Hands-on: Measure memory bandwidth 
* Choose either C/C++ (`c` and `ctrad`) or Fortran (`fortran`). Both of them are fine, as well.


## C/C++
### How to execute
#### 1. Edit a job script
* Before trying this hands-on, you need to do `00_stream` to compile STREAM.
* We have three working directories, `c/fj_zfill`, `c/fj`, and `ctrad/fj_zfill`. Under each of directories, you can find:
  * `run.sh` : a script to execute STREAM
  * `task.sh`: a job script to run STREAM with different kinds of settings
* edit `task.sh` (modify `--gname` option).
* Edit `BINDIR` variable in `run.sh` before the execution. You need to write your installed location of STREAM binary (e.g., `stream.exe`) there.

#### 2. Run program
* You can run the program either:
```
## Here is an example of c/fj_zfill.
## To run as a batch job
$ cd c/fj_zfill
$ pjsub task.sh 
## Or, to run in an interactive job
$ cd c/fj_zfill
$ bash task.sh 
```
* Each of the cases in the Exercises will be completed within 3-4 minutes. 
  * For safety, we set the job elapsed time in the job scripts is 6 minutes.

### Exercises A 
* E1: Check `task.sh` in `c/fj_zfill`, for example. You can find that the number of OpenMP threads varies from 1 to 48 via `NTHREADS` variable. 
* E2: Run the STREAM benchmark (`stream.exe`) in `c/fj_zfill/`,`c/fj/`, and `ctrad/fj_zfill`. Check the results in `Best Rate (MB/s)` of functions `Add ` and `Triad` in 48 threads. 
* E3: Compare the measurement results to the peak performance of memory bandwidth in A64FX.


## Fortran
### How to execute
#### 1. Edit a job script
* Before trying this hands-on, you need to do `00_stream` to compile STREAM.
* We have two working directories, `fortran/fj_zfill` and `fortran/fj`. Under each of directories, you can find:
  * `run.sh` : a script to execute STREAM
  * `task.sh`: a job script to run STREAM with different kinds of settings
* edit `task.sh` (modify `--gname` option).
* Edit `BINDIR` variable in `run.sh` before the execution. You need to write your installed location of STREAM binary (e.g., `stream.exe`) there.

#### 2. Run program
* You can run the program either:
```
## Here is an example of fortran/fj_zfill.
## To run as a batch job
$ cd fortran/fj_zfill
$ pjsub task.sh 
## Or, to run in an interactive job
$ cd fortran/fj_zfill
$ bash task.sh 
```
* Each of the cases in the Exercises will be completed within 3-4 minutes. 
  * For safety, we set the job elapsed time in the job scripts is 6 minutes.

### Exercises A
* E1: Check `task.sh` in `fortran/fj_zfill`, for example. You can find that the number of OpenMP threads varies from 1 to 48 via `NTHREADS` variable. 
* E2: Run the STREAM benchmark (`stream.exe`) in `fortran/fj_zfill/` and `fortran/fj/`. Check the results in `Rate (MB/s)` of functions `Add ` and `Triad` in 48 threads. 
* E3: Compare the measurement results to the peak performance of memory bandwidth in A64FX.