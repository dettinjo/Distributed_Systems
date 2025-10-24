#!/bin/bash

#SBATCH --job-name=make_plot
#SBATCH --partition=cuda-ext.q
#SBATCH --output=slurm_plot_%j.out
#SBATCH --ntasks=1

# --- FINAL CORRECTION FOR YOUR SYSTEM ---
# Load the Miniconda module to provide a Python environment with scientific libraries.
module load miniconda/3

echo "--- SLURM Plotting Job Started ---"

# Check that the Makefile passed the correct number of arguments.
if [ "$#" -ne 2 ]; then
    echo "Error: This script requires an input .dat file and an output .png file."
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="$2"

echo "Input data file: $INPUT_FILE"
echo "Output plot file: $OUTPUT_FILE"

# Use the python3 command to run the script.
# The 'miniconda/3' module ensures 'python3' is in the PATH and has matplotlib.
python3 plotcounts.py "$INPUT_FILE" "$OUTPUT_FILE"

echo "--- SLURM Plotting Job Finished ---"