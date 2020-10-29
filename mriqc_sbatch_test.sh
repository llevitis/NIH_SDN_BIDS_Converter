#!/bin/bash 

#SBATCH --array=1-256
#SBATCH --time=03:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G

module load mriqc/0.15.1
cd /data/DNU/liza/data/XXY

# exxtract ssubjects
SUBJECT=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /data/DNU/liza/data/XXY/demo_data/XXY_3TC_PseudoGUIDs.txt )

mriqc Nifti Nifti/derivatives/MRIQC participant --participant_label ${SUBJECT} \
--n_procs 10 \
--mem_gb 8 \
--no-sub

