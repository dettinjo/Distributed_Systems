#!/bin/bash
#SBATCH --job-name=job4
#SBATCH --partition=cuda-ext.q
#SBATCH --nodes=1
#SBATCH --output=job4-%j.out
#SBATCH --time=00:05:00

echo "Job 4 output" | tee -a jobid.txt
