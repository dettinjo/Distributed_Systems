#!/bin/bash

#SBATCH --job-name=final_step
#SBATCH --partition=aolin.q
#SBATCH --output=final_%j.out
#SBATCH --ntasks=1

echo "Stage 3: The final job is running."
sleep 10
echo "Stage 3: The final job has finished."