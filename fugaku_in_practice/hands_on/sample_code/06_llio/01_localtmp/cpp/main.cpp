/* Copyright 2025 Research Organization for Science and Technology */

#include <mpi.h>
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>
#include <cmath>

std::string add_myrank_to_filename(int, std::string);

int main(int argc, char* argv[])
{
   const int main_rank = 0;
   int myrank, nprocs;
   std::string input_file;
   std::string output_file;
   FILE *ofs;

   int array_size;
   int i_skip, n_loop;
   double x;

   double t1, total1;
   double t2, total2;
   double *A;

   std::string tmp;

   MPI_Init(&argc, &argv);
   MPI_Comm_size(MPI_COMM_WORLD, &nprocs);
   MPI_Comm_rank(MPI_COMM_WORLD, &myrank);

   if (argc > 1) {
      input_file = argv[1];

      std::ifstream infil(input_file, std::ios::in);
      if (!infil) {
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
   } catch (const std::bad_alloc& e) {
      std::cerr << "Memory Allocation Error: " <<  e.what() << std::endl;
      MPI_Abort(MPI_COMM_WORLD, 90);
      return EXIT_FAILURE;
   }

   for (int ii = 0; ii < array_size; ii++){
      A[ii] = 1.0 - 1.0 / (double)(ii+1);
   }

   output_file = add_myrank_to_filename(myrank, output_file);

   MPI_Barrier(MPI_COMM_WORLD);
   total1 = MPI_Wtime();

   for (int ii = 1; ii <= n_loop; ii++) {

      if (ii%i_skip == 0) {
         MPI_Barrier(MPI_COMM_WORLD);
         t1 = MPI_Wtime();

         ofs = fopen(output_file.c_str(), "wb");

         if (!ofs) {
            std::cerr << "File Open Error: " << output_file << std::endl;
            MPI_Abort(MPI_COMM_WORLD, 99);
            return EXIT_FAILURE;
         }
         fwrite(A, sizeof(double), array_size, ofs);
         fclose(ofs);

         MPI_Barrier(MPI_COMM_WORLD);
         t2 = MPI_Wtime();

         if (myrank == main_rank) {
            std::cout << "    II= " << ii << "  ELAPSED(SEC) = " << t2 - t1 << std::endl;
         }        
      }
   }
   MPI_Barrier(MPI_COMM_WORLD);
   total2 = MPI_Wtime();

   if (myrank == main_rank) {
      std::cout<< " NPROCS = " << nprocs << "  TOTAL ELAPSED(SEC) = " << total2 - total1 << std::endl;
   }

   delete[] A;
   MPI_Finalize();

   return EXIT_SUCCESS;
}

std::string add_myrank_to_filename(int myrank, std::string filename){

   std::string s_myrank = std::to_string(myrank);
   std::string file_with_rank = filename + "_" + s_myrank;

   return file_with_rank;
}
