#!/bin/bash

#SBATCH --job-name=hello_hybrid
#SBATCH --output=hybrid_test.out
#SBATCH --partition=aolin.q

# Configuration for 2 nodes, 2 processes/node, 6 threads/process.
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=6

# Load the required compiler and MPI library environment.
module load gcc/13.2.1
module load openmpi/4.1.1

# Set the OpenMP thread count for each MPI process based on
# the number of CPUs allocated per task by SLURM.
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

echo "Running with $SLURM_NNODES nodes, $SLURM_NTASKS_PER_NODE processes/node, and $OMP_NUM_THREADS threads/process."
echo "==============================================================================="

# Launch the hybrid application using the mpirun launcher, as this system's
# Open MPI is not configured for direct launch with srun.
mpirun "$SLURM_SUBMIT_DIR/hellohybrid"