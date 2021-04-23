#!/bin/bash 
#SBATCH --array 1-90 
#SBATCH --time=16:00:00 
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G 

module load singularity 

# extract subject IDs from text file 
SUBJECT=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /data/DNU/liza/data/DownSyndrome/DS_3TA_PseudoGUIDs.txt )

singularity run \
--bind /data/DNU \
/data/DNU/liza/singularity_imgs/freesurfer_v7.1.1.sif \
/data/DNU/liza/data/DownSyndrome/Nifti \
/data/DNU/liza/data/DownSyndrome/Nifti/derivatives/Freesurfer \
participant \
--participant_label ${SUBJECT} \
--license_file "/data/DNU/liza/license.txt" \
--skip_bids_validator


# /usr/local/apps/freesurfer/7.1.1/license.txt
