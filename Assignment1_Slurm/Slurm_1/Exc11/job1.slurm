#!/bin/bash
#SBATCH --job-name=job1
#SBATCH --partition=cuda-ext.q
#SBATCH --output=job1.out
echo "Job 1 is running"; sleep 20; echo "Job 1 finished."