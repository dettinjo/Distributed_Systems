#!/bin/bash

#SBATCH --job-name=sort_array
#SBATCH --partition=aolin.q
#SBATCH --output=sort_array_%A_%a.out

# Define a job array with tasks numbered from 0 to 3.
# SLURM will run this script 4 times.
#SBATCH --array=0-3

echo "--- Starting sort task $SLURM_ARRAY_TASK_ID ---"

# Set filenames based on the unique task ID provided by SLURM.
input_file="$SLURM_SUBMIT_DIR/names_${SLURM_ARRAY_TASK_ID}.txt"
output_file="$SLURM_SUBMIT_DIR/names_${SLURM_ARRAY_TASK_ID}.sorted"

echo "Sorting $input_file -> $output_file"

# Execute the sort command for this specific task.
sort "$input_file" > "$output_file"

echo "--- Task $SLURM_ARRAY_TASK_ID complete ---"