#!/bin/bash
#SBATCH --job-name=job2
#SBATCH --partition=cuda-ext.q
#SBATCH --nodes=1
#SBATCH --output=job2-%j.out
#SBATCH --time=00:05:00

echo "Job 2 output" | tee -a job-2-3.txt
