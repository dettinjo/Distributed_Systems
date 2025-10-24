#!/bin/bash

echo "--- Submitting workflow ---"

# Submit the first job and capture its ID
job1_id=$(sbatch --parsable job1.slurm)
echo "Submitted Job 1 with ID: $job1_id"

# Submit jobs 2 and 3, making them dependent on Job 1
job2_id=$(sbatch --parsable --dependency=afterok:$job1_id job2.slurm)
echo "Submitted Job 2 with ID: $job2_id (waits for Job 1)"

job3_id=$(sbatch --parsable --dependency=afterok:$job1_id job3.slurm)
echo "Submitted Job 3 with ID: $job3_id (waits for Job 1)"

# --- CORRECTED LINE ---
# Submit job 4, making it dependent on BOTH Job 2 and Job 3 using the correct syntax
job4_id=$(sbatch --parsable --dependency=afterok:$job2_id:$job3_id job4.slurm)
# --------------------

echo "Submitted Job 4 with ID: $job4_id (waits for Jobs 2 & 3)"

echo "--- Workflow submitted. Use 'squeue -u $USER' to monitor. ---"