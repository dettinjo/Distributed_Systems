#include <stdio.h>
#include <omp.h>
#include "mpi.h"
#include <unistd.h>

int work=1200;

int main(int argc, char *argv[]) {
  int numprocs, rank, namelen;
  char processor_name[MPI_MAX_PROCESSOR_NAME];
  int iam = 0, np = 1;
  int my_work;

  MPI_Init(&argc, &argv);
  MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Get_processor_name(processor_name, &namelen);
  my_work = work/numprocs;
//  printf ("My work %d is %d \n", rank, my_work);

    
  #pragma omp parallel default(shared) private(iam, np)
  {
    np = omp_get_num_threads();
    iam = omp_get_thread_num();
    int my_sleep=my_work/np;
    sleep (my_sleep);
    printf("Hello from thread %d out of %d from process %d out of %d on %s ; SLEEP: %d\n",
           iam, np, rank, numprocs, processor_name,my_sleep );
  }

  MPI_Finalize();
}
