/* Copyright 2025 Research Organization for Science and Technology */

#include <mpi.h>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>
#include <cmath>

int main(int argc, char* argv[])
{
   const int main_rank = 0;
   int myrank, nprocs;
   MPI_Offset offset;
   MPI_File ifh;

   int array_size;
   int i_skip, n_loop;
   std::string input_file, output_file;

   double *A;
   double t1, total1;
   double t2, total2;

   std::string tmp;

   MPI_Init(&argc, &argv);
   MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
   MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

   if (argc > 1) {
      input_file = argv[1];

      std::ifstream infil(input_file, std::ios::in);
      if (!infil){
         std::cerr << "File Open Error: " << input_file << std::endl;
         MPI_Finalize();
         return EXIT_FAILURE;
      }

      getline(infil, tmp);
      array_size = stoi(tmp);

      getline(infil, tmp);
      n_loop = stoi(tmp);

      getline(infil, tmp);
      i_skip = stoi(tmp);

      getline(infil, tmp);
      output_file = tmp;

      infil.close();
   } else {
      array_size = 20;
      n_loop = 100;
      i_skip = 5;
      output_file = "./output.txt";
   }

   if (myrank == main_rank) {
      std::cout << " NPROCS = " << nprocs << " ";
      std::cout << " MYRANK = " << myrank << " ";
      std::cout << " DATA_SIZE = " << array_size << " (" << array_size * 8.0 / (1024.0 * 1024.0) << " MiB) ";
      std::cout << " NLOOP = " << n_loop << " ";
      std::cout << " ISKIP = " << i_skip << std::endl;
   }

   try {
      A = new double[array_size];
   } catch (const std::bad_alloc& e){
      std::cerr << "Memory Allocation Error: " << e.what() << std::endl;
      MPI_Abort(MPI_COMM_WORLD, 90);
      return EXIT_FAILURE;
   }

   for (int ii = 0; ii < array_size; ii++) {
      A[ii] = 1.0 - 1.0 / (double)(ii+1);
   }

   MPI_Barrier(MPI_COMM_WORLD);
   total1 = MPI_Wtime();

   for (int ii = 0; ii < n_loop; ii++) {

      if (ii%i_skip == 0) {
         MPI_Barrier(MPI_COMM_WORLD);
         t1 = MPI_Wtime();

         offset = (array_size * 8.0) * myrank;
         MPI_File_open(MPI_COMM_WORLD, output_file.c_str(), MPI_MODE_WRONLY+MPI_MODE_CREATE, MPI_INFO_NULL, &ifh);
         MPI_File_write_at(ifh, offset, A, array_size, MPI_DOUBLE, MPI_STATUS_IGNORE);
         MPI_File_close(&ifh);

         MPI_Barrier(MPI_COMM_WORLD);
         t2 = MPI_Wtime();

         if (myrank == main_rank) {
            std::cout << "    II= " << ii << "  ELAPSED (SEC)= " << t2-t1 << std::endl; 
         }
      }
   }

   MPI_Barrier(MPI_COMM_WORLD);
   total2 = MPI_Wtime();
   if (myrank == main_rank) {
      std::cout << " NPROCS = " << nprocs << "  LOOP ELAPSED (SEC)= " << total2 - total1 << std::endl;
   }

   delete[] A;
   MPI_Finalize();
 
   return EXIT_SUCCESS;
}
