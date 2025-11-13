#!/bin/bash

#SBATCH --job-name=intermediate_steps
#SBATCH --partition=aolin.q
#SBATCH --output=intermediate_%A_%a.out  # %A is the main Job ID, %a is the task ID
#SBATCH --ntasks=1

echo "Stage 2: Intermediate task $SLURM_ARRAY_TASK_ID is running."
sleep 30 # Sleep to make the dependency visible
echo "Stage 2: Intermediate task $SLURM_ARRAY_TASK_ID has finished."