#!/bin/bash

#SBATCH --job-name=serial_pi_workflow
#SBATCH --partition=aolin.q
#SBATCH --output=serial_pi_workflow_%j.out
#SBATCH --ntasks=1

echo "--- Starting Serial Workflow ---"
start=$(date +%s)

# Execute six instances of the program sequentially.
"$SLURM_SUBMIT_DIR/serial_pi"
"$SLURM_SUBMIT_DIR/serial_pi"
"$SLURM_SUBMIT_DIR/serial_pi"
"$SLURM_SUBMIT_DIR/serial_pi"
"$SLURM_SUBMIT_DIR/serial_pi"
"$SLURM_SUBMIT_DIR/serial_pi"

end=$(date +%s)
echo "--- Serial Workflow Finished ---"
echo "Total Elapsed Time: $(($end-$start)) seconds"