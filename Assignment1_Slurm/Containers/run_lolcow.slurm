#!/bin/bash

#SBATCH --job-name=lolcow_batch
#SBATCH --partition=cuda-ext.q
#SBATCH --output=lolcow_batch_%j.out
#SBATCH --ntasks=1

echo "--- Running lolcow container in batch mode ---"

# Execute the container's default runscript by calling the .sif file directly.
# The path is resolved using the SLURM_SUBMIT_DIR variable.
"$SLURM_SUBMIT_DIR/lolcow.sif"

echo "--- Container run finished. ---"