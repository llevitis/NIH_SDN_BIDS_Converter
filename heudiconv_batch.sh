#!/bin/bash 
#SBATCH --array 1-257 
#SBATCH --time=03:00:00 
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G 

module load singularity 

# extract subject IDs from text file 
SUBJECT=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /data/DNU/liza/data/XXY/demo_data/XXY_3TC_PseudoGUIDs.txt )

singularity run \
--bind /data/DNU \
/data/DNU/liza/singularity_imgs/heudiconv_0.5.4.sif \
-d /data/DNU/liza/data/XXY/dicom/sub-{subject}/ses-{session}/*/mr_*/*.dcm \
-o /data/DNU/liza/data/XXY/Nifti/ \
-f /data/DNU/liza/code/NIH_SDN_BIDS_Converter/heuristic.py \
-s ${SUBJECT} \
-ss v01 \
-c dcm2niix \
-b \
--overwrite \
--minmeta
