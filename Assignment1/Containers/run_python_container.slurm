#!/bin-bash

#SBATCH --job-name=python_container
#SBATCH --partition=cuda-ext.q
#SBATCH --output=python_container_%j.out
#SBATCH --ntasks=1

echo "--- Running seq_primes.py inside a Python container ---"

# Use 'apptainer exec' to run a command inside the specified container.
# The first argument is the container image.
# The second argument is the command to run inside the container ('python').
# Subsequent arguments are passed to that command.
apptainer exec "$SLURM_SUBMIT_DIR/python-3.9.6.sif" python "$SLURM_SUBMIT_DIR/seq_primes.py" 2 100

echo "--- Python script finished. ---"