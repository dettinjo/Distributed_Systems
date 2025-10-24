#!/bin/bash

#SBATCH --job-name=initial_step
#SBATCH --partition=aolin.q
#SBATCH --output=initial_%j.out
#SBATCH --ntasks=1

echo "Stage 1: The initial job is running."
sleep 20 # Sleep to make the dependency visible
echo "Stage 1: The initial job has finished."