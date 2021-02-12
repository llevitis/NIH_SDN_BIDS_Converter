#!/bin/bash
#SBATCH --array=1-256
#SBATCH --time=1:00:00 

module load TORTOISE

SUBJECT=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /data/DNU/liza/data/XXY/demo_data/XXY_3TC_PseudoGUIDs.txt )

dicom_dir='/data/DNU/liza/data/XXY/dicom'
dwi_dicom_dir='/data/DNU/liza/data/XXY/dwi_dicom'
ses='v01'
bids_dir='/data/DNU/liza/data/XXY/Nifti'

./convert_dwi_tortoise_bids.sh $dicom_dir $dwi_dicom_dir $SUBJECT $ses $bids_dir 
