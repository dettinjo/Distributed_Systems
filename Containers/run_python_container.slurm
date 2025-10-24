#!/bin/bash

#SBATCH --job-name=python_container
#SBATCH --partition=cuda-ext.q
#SBATCH --output=python_container_%j.out
#SBATCH --ntasks=1

echo "--- Running seq_prime.py inside a Python container ---"

# The command to execute:
# apptainer exec [container_path] [command_to_run_inside] [arguments_for_that_command]
apptainer exec "$SLURM_SUBMIT_DIR/python-3.9.6.sif" python "$SLURM_SUBMIT_DIR/seq_prime.py" 2 100

echo "--- Python script finished. ---"