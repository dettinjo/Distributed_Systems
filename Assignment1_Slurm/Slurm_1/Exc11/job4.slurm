#!/bin/bash
#SBATCH --job-name=job4
#SBATCH --partition=cuda-ext.q 
#SBATCH --output=job4.out
echo "Job 4 is running"; sleep 20; echo "Job 4 finished."