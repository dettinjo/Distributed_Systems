#!/bin/bash

#SBATCH --job-name=sort_array
#SBATCH --partition=aolin.q
#SBATCH --output=sort_array_%A_%a.out  # %A=Job ID, %a=Task ID

# CRITICAL: Define the job array. This creates 4 tasks with IDs 0, 1, 2, 3.
#SBATCH --array=0-3

echo "--- Starting sort task $SLURM_ARRAY_TASK_ID ---"

# Define input and output file names using the task ID
input_file="$SLURM_SUBMIT_DIR/names_${SLURM_ARRAY_TASK_ID}.txt"
output_file="$SLURM_SUBMIT_DIR/names_${SLURM_ARRAY_TASK_ID}.sorted"

echo "Sorting $input_file -> $output_file"

# Execute the sort command for this specific task
sort "$input_file" > "$output_file"

echo "--- Task $SLURM_ARRAY_TASK_ID complete ---"