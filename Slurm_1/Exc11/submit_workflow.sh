#!/bin/bash

echo "--- Submitting workflow ---"

# Submit the first job and store its ID.
job1_id=$(sbatch --parsable job1.slurm)
echo "Submitted Job 1 with ID: $job1_id"

# Submit jobs 2 and 3 with a dependency on the first job.
job2_id=$(sbatch --parsable --dependency=afterok:$job1_id job2.slurm)
echo "Submitted Job 2 with ID: $job2_id (waits for Job 1)"

job3_id=$(sbatch --parsable --dependency=afterok:$job1_id job3.slurm)
echo "Submitted Job 3 with ID: $job3_id (waits for Job 1)"

# Submit job 4, making it dependent on the completion of both jobs 2 and 3.
job4_id=$(sbatch --parsable --dependency=afterok:$job2_id:$job3_id job4.slurm)
echo "Submitted Job 4 with ID: $job4_id (waits for Jobs 2 & 3)"

echo "--- Workflow submitted. Use 'squeue -u $USER' to monitor. ---"