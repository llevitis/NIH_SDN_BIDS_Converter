#!/bin/bash 

module load singularity 

singularity run \
--bind /data/DNU \
/data/DNU/liza/singularity_imgs/heudiconv_0.5.4.sif \
-d /data/DNU/liza/data/XXY/dicom/sub-{subject}/ses-{session}/*/mr_*/*.dcm \
-o /data/DNU/liza/data/XXY/Nifti/ \
-f /data/DNU/liza/code/NIH_SDN_BIDS_Converter/heuristic.py \
-s 00660 \
-ss v01 \
-c dcm2niix \
-b \
--overwrite
