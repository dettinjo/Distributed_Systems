#!/bin/bash
#SBATCH --job-name=job1
#SBATCH --partition=cuda-ext.q
#SBATCH --nodes=1
#SBATCH --output=job1-%j.out
#SBATCH --time=00:05:00

echo "Job 1 output" | tee jobid.txt
