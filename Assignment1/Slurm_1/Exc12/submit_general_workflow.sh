#!/bin/bash

# Ensure a command-line argument is provided for the number of intermediate jobs.
if [ -z "$1" ]; then
  echo "Usage: $0 <number_of_intermediate_jobs>"
  exit 1
fi
n=$1

echo "--- Submitting a 1 -> $n -> 1 workflow ---"

# Stage 1: Submit the initial job and capture its ID.
initial_id=$(sbatch --parsable initial.slurm)
echo "Submitted Initial Job with ID: $initial_id"

# Stage 2: Submit the intermediate jobs as a job array.
# The array's execution is dependent on the successful completion of the initial job.
array_id=$(sbatch --parsable --dependency=afterok:$initial_id --array=1-$n intermediate.slurm)
echo "Submitted Intermediate Job Array with main ID: $array_id (waits for Job $initial_id)"

# Stage 3: Submit the final job.
# This job is dependent on the successful completion of the entire job array.
final_id=$(sbatch --parsable --dependency=afterok:$array_id final.slurm)
echo "Submitted Final Job with ID: $final_id (waits for Array $array_id)"

echo "--- Workflow successfully submitted. ---"
echo "Use 'squeue -u $USER' to monitor."