#!/bin/bash
#SBATCH --array=1-256
#SBATCH --time=0:10:00

module load freesurfer

SUBJECT=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /data/DNU/liza/data/XXY/demo_data/XXY_3TC_PseudoGUIDs.txt )

freesurfer_dir='/data/DNU/liza/data/XXY/Nifti/derivatives/Freesurfer/'
bids_dir='/data/DNU/liza/data/XXY/'
ses='v01'

mri_label2vol \
--seg ${freesurfer_dir}/sub-${SUBJECT}/parcellation/HCP.nii.gz \
--temp ${bids_dir}/sub-${SUBJECT}/ses-${ses}/anat/sub-${SUBJECT}_ses-${ses}_T1w.nii.gz \
--o ${freesurfer_dir}/sub-${SUBJECT}/parcellation/HCP_space-T1w.nii.gz \
--regheader ${freesurfer_dir}/sub-${SUBJECT}/parcellation/HCP.nii.gz
