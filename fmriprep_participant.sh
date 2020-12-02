#!/bin/bash 

#SBATCH --array=1-256
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=32gb

module load fmriprep/20.2.0
cd /data/DNU/liza/data/XXY
# Make sure FS_LICENSE is defined in the container.
export SINGULARITYENV_FS_LICENSE=/data/DNU/liza/license.txt
# extract subjects
SUBJECT=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /data/DNU/liza/data/XXY/demo_data/XXY_3TC_PseudoGUIDs.txt )

fmriprep Nifti Nifti/derivatives/ participant --participant_label ${SUBJECT} \
--notrack \
--nthreads 16 \
--omp-nthreads 16 \
--fs-subjects-dir Nifti/derivatives/Freesurfer \
--output-spaces T1w MNI152NLin2009cAsym \
--skip_bids_validation
