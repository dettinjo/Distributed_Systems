#!/bin/bash

#SBATCH --job-name=lolcow_batch
#SBATCH --partition=cuda-ext.q
#SBATCH --output=lolcow_batch_%j.out
#SBATCH --ntasks=1

echo "--- Running lolcow container in batch mode ---"

# Execute the container using its full path.
# The double quotes handle any spaces in the directory path.
"$SLURM_SUBMIT_DIR/lolcow.sif"

echo "--- Container run finished. ---"