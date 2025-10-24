#!/bin/bash
#SBATCH --job-name=job3
#SBATCH --partition=cuda-ext.q
#SBATCH --nodes=1
#SBATCH --output=job3-%j.out
#SBATCH --time=00:05:00

echo "Job 3 running"
sleep 10
