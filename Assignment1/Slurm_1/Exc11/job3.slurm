#!/bin/bash
#SBATCH --job-name=job3
#SBATCH --partition=cuda-ext.q 
#SBATCH --output=job3.out
echo "Job 3 is running"; sleep 20; echo "Job 3 finished."