#!/bin/bash 

#SBATCH --array=1-90
#SBATCH --time=03:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G

module load mriqc/0.15.1
cd /data/DNU/liza/data/DownSyndrome

# exxtract ssubjects
SUBJECT=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /data/DNU/liza/data/DownSyndrome/DS_3TA_PseudoGUIDs.txt )

mriqc Nifti Nifti/derivatives/MRIQC participant --participant_label ${SUBJECT} \
--n_procs 10 \
--mem_gb 8 \
--no-sub

