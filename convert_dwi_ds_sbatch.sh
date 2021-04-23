#!/bin/bash
#SBATCH --array=1-76
#SBATCH --time=1:00:00 

module load TORTOISE

SUBJECT=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /data/DNU/liza/data/DownSyndrome/DS_3TA_PseudoGUIDs.txt )

dicom_dir='/data/DNU/liza/data/DownSyndrome/DICOM'
dwi_dicom_dir='/data/DNU/liza/data/DownSyndrome/dwi_dicom'
ses='v01'
bids_dir='/data/DNU/liza/data/DownSyndrome/Nifti'

./convert_dwi_tortoise_ds_bids.sh $dicom_dir $dwi_dicom_dir $SUBJECT $ses $bids_dir 
