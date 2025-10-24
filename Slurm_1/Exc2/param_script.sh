#!/bin/bash
#SBATCH --job-name=replacejob
#SBATCH --partition=cuda-ext.q
#SBATCH --nodes=1
#SBATCH --output=%x-%j.output

echo "This output will go to the custom output file."