#!/bin/bash

#SBATCH --job-name=hello_hybrid
#SBATCH --output=hybrid_test.out
#SBATCH --partition=aolin.q

# Node and Process Configuration (Modify for each test)
#SBATCH --nodes=2
#SBATCH --ntasks-per-node=2
#SBATCH --cpus-per-task=6

# --- CRITICAL ---
# Load the CORRECT and AVAILABLE modules for your system
# (Make sure these are the versions you found with 'module avail')
module load gcc/13.2.1
module load openmpi/4.1.1
# ----------------

# Set the number of OpenMP threads for each MPI process
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

echo "Running with $SLURM_NNODES nodes, $SLURM_NTASKS_PER_NODE processes/node, and $OMP_NUM_THREADS threads/process."
echo "==============================================================================="

# --- SOLUTION ---
# Launch the hybrid application using 'mpirun' instead of 'srun'
mpirun "$SLURM_SUBMIT_DIR/hellohybrid"
# ----------------