#!/bin/bash 

#SBATCH --array=1-76
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=32gb

module load fmriprep/20.2.0
cd /data/DNU/liza/data/DownSyndrome
# Make sure FS_LICENSE is defined in the container.
export SINGULARITYENV_FS_LICENSE=/data/DNU/liza/license.txt
# extract subjects
SUBJECT=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /data/DNU/liza/data/DownSyndrome/DS_3TA_PseudoGUIDs.txt )

fmriprep Nifti Nifti/derivatives/ participant --participant_label ${SUBJECT} \
--notrack \
--nthreads 16 \
--omp-nthreads 16 \
--fs-subjects-dir Nifti/derivatives/Freesurfer \
--use-syn-sdc \
--output-spaces T1w MNI152NLin2009cAsym \
--skip_bids_validation
