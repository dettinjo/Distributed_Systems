#!/bin/bash

#SBATCH --job-name=parallel_pi_workflow
#SBATCH --partition=aolin.q
#SBATCH --output=parallel_pi_workflow_%j.out
#SBATCH --nodes=1
#SBATCH --ntasks=4

echo "--- Starting Parallel Workflow ---"
start=$(date +%s)

echo "Running starting task..."
"$SLURM_SUBMIT_DIR/serial_pi"

echo "Running 4 intermediate tasks in parallel..."
"$SLURM_SUBMIT_DIR/serial_pi" &
"$SLURM_SUBMIT_DIR/serial_pi" &
"$SLURM_SUBMIT_DIR/serial_pi" &
"$SLURM_SUBMIT_DIR/serial_pi" &

echo "Waiting for parallel tasks to complete..."
wait

echo "Running ending task..."
"$SLURM_SUBMIT_DIR/serial_pi"

end=$(date +%s)
echo "--- Parallel Workflow Finished ---"
echo "Total Elapsed Time: $(($end-$start)) seconds"