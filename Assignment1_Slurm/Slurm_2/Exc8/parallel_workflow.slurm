#!/bin/bash

#SBATCH --job-name=parallel_pi_workflow
#SBATCH --partition=aolin.q
#SBATCH --output=parallel_pi_workflow_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=4 # Allocate enough tasks for the parallel portion.

echo "--- Starting Parallel Workflow ---"
start=$(date +%s)

# Stage 1: Run the initial task.
echo "Running starting task..."
"$SLURM_SUBMIT_DIR/serial_pi"

# Stage 2: Run four intermediate tasks in parallel as background jobs.
echo "Running 4 intermediate tasks in parallel..."
"$SLURM_SUBMIT_DIR/serial_pi" &
"$SLURM_SUBMIT_DIR/serial_pi" &
"$SLURM_SUBMIT_DIR/serial_pi" &
"$SLURM_SUBMIT_DIR/serial_pi" &

# Stage 3: Wait until all background tasks from this script have finished.
echo "Waiting for parallel tasks to complete..."
wait

# Stage 4: Run the final task.
echo "Running ending task..."
"$SLURM_SUBMIT_DIR/serial_pi"

end=$(date +%s)
echo "--- Parallel Workflow Finished ---"
echo "Total Elapsed Time: $(($end-$start)) seconds"