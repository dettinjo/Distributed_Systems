#!/bin/bash
#SBATCH --job-name=sort-folder-array
#SBATCH --partition=cuda-ext.q
#SBATCH --array=0-9

for i in {0..9}; do
  mkdir -p folder${i}
  echo -e "zeta\nalpha\nbeta" > folder${i}/names.txt
done

if [ -f "$infile" ]; then
  sort "$infile" > "$outfile"
else
  echo "No input file $infile. Skipping."
fi

folder="folder${SLURM_ARRAY_TASK_ID}"       # Select folder depending on array index
infile="${folder}/names.txt"                # Input file in the folder
outfile="${folder}/names.sorted"            # Output file in the same folder

sort "$infile" > "$outfile"
