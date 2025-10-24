#!/bin/bash

#SBATCH --job-name=balanced_16
#SBATCH --partition=cuda-ext.q
#SBATCH --output=balanced_16_%j.out


# Request a total of 2 nodes for the job
#SBATCH --nodes=2

# Request a total of 16 tasks to be executed
#SBATCH --ntasks=16

# CRITICAL: Specify that exactly 8 tasks should be run on each node
#SBATCH --ntasks-per-node=8

echo "Executing 16 tasks balanced across 2 nodes..."
echo "---------------------------------------------"

# srun will launch 16 instances of the 'hostname' command.
# We pipe the output to 'sort' and 'uniq -c' to count the executions on each node.
srun hostname | sort | uniq -c