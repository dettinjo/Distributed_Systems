#!/bin/bash
#SBATCH --job-name=simpletest
#SBATCH --partition=cuda-ext.q
#SBATCH --nodes=1

echo "I have written a submit script" > text.txt
sleep 10
ls -l
