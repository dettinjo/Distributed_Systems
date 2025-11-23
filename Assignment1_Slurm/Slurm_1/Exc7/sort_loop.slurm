#!/bin/bash

#SBATCH --job-name=sort_loop
#SBATCH --partition=aolin.q
#SBATCH --output=sort_loop_%j.out
#SBATCH --ntasks=1

echo "--- Starting file sort using a for loop ---"

# Iterate through the files numbered 0 to 3.
for i in {0..3}
do
  # Set the input and output filenames for the current iteration.
  input_file="$SLURM_SUBMIT_DIR/names_${i}.txt"
  output_file="$SLURM_SUBMIT_DIR/names_${i}.sorted"

  echo "Sorting $input_file -> $output_file"
  
  # Run the sort command.
  sort "$input_file" > "$output_file"
done

echo "--- Sort complete. Verifying output files: ---"
ls -l *.sorted