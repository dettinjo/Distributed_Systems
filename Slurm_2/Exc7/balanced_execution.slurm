#!/bin/bash

#SBATCH --job-name=balanced_16
#SBATCH --partition=cuda-ext.q
#SBATCH --output=balanced_16_%j.out

# Request 2 nodes for this job.
#SBATCH --nodes=2

# Request a total of 16 tasks.
#SBATCH --ntasks=16

# Ensure an even distribution by assigning 8 tasks to each node.
#SBATCH --ntasks-per-node=8

echo "Executing 16 tasks balanced across 2 nodes..."
echo "---------------------------------------------"

# srun launches the hostname command on all allocated tasks.
# The output is then sorted and counted to verify the distribution.
srun hostname | sort | uniq -c