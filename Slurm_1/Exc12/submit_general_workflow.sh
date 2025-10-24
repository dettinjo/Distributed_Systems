#!/bin/bash

# --- Parameter Check ---
# This section checks if you provided a number when running the script.
if [ -z "$1" ]; then
  echo "ERROR: You must specify the number of intermediate jobs."
  echo "Usage: ./submit_general_workflow.sh <number>"
  exit 1
fi
n=$1 # Store the first argument in the variable 'n'

echo "--- Submitting a workflow with 1 -> $n -> 1 structure ---"

# --- STAGE 1 ---
# Submit the initial job and capture its Job ID.
initial_id=$(sbatch --parsable initial.slurm)
echo "Submitted Initial Job with ID: $initial_id"

# --- STAGE 2 ---
# Submit the intermediate jobs as a single job array.
# The '--dependency' flag makes the entire array wait for the initial job.
# The '--array' flag tells SLURM to create 'n' tasks, numbered 1 to n.
array_id=$(sbatch --parsable --dependency=afterok:$initial_id --array=1-$n intermediate.slurm)
echo "Submitted Intermediate Job Array with main ID: $array_id (waits for Job $initial_id)"

# --- STAGE 3 ---
# Submit the final job.
# The '--dependency' flag makes it wait for the ENTIRE job array to complete.
# SLURM is smart enough to know that depending on the array's main ID means waiting for all of its tasks.
final_id=$(sbatch --parsable --dependency=afterok:$array_id final.slurm)
echo "Submitted Final Job with ID: $final_id (waits for Array $array_id)"

echo "--- Workflow successfully submitted. ---"
echo "Use 'squeue -u $USER' to monitor the progress."