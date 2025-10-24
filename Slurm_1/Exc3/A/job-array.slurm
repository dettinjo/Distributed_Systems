#!/bin/bash
#SBATCH --job-name=odd-array
#SBATCH --partition=cuda-ext.q
#SBATCH --array=1,3,5,7,9,11,13,15,17,19

echo "This is SLURM array task $SLURM_ARRAY_TASK_ID"
# (You can put your real compute command here)
