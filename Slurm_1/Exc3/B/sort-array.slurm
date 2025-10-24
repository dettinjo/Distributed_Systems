#!/bin/bash
#SBATCH --job-name=sort-array
#SBATCH --partition=cuda-ext.q
#SBATCH --array=0-9

for i in {0..9}; do
  echo -e "zeta\nalpha\nbeta" > names${i}.txt
done

infile="names${SLURM_ARRAY_TASK_ID}.txt"
outfile="names${SLURM_ARRAY_TASK_ID}.sorted"
sort "$infile" > "$outfile"
