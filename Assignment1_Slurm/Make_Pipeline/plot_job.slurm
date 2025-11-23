#!/bin/bash

#SBATCH --job-name=make_plot
#SBATCH --partition=cuda-ext.q
#SBATCH --output=slurm_plot_%j.out
#SBATCH --ntasks=1

echo "--- SLURM Plotting Job Started ---"

# Load the Miniconda environment to ensure Python and its scientific
# libraries, like matplotlib, are available.
module load miniconda/3

# Check for the two arguments (input and output file) passed by the Makefile.
if [ "$#" -ne 2 ]; then
    echo "Error: This script requires an input .dat file and an output .png file."
    exit 1
fi

# Assign the command-line arguments to variables for clarity.
INPUT_FILE="$1"
OUTPUT_FILE="$2"

echo "Input data file: $INPUT_FILE"
echo "Output plot file: $OUTPUT_FILE"

# Execute the Python plotting script.
python3 plotcounts.py "$INPUT_FILE" "$OUTPUT_FILE"

echo "--- SLURM Plotting Job Finished ---"