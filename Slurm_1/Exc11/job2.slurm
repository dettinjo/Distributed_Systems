#!/bin/bash
#SBATCH --job-name=job2
#SBATCH --partition=cuda-ext.q 
#SBATCH --output=job2.out
echo "Job 2 is running"; sleep 20; echo "Job 2 finished."