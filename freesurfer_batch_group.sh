#!/bin/bash 
#SBATCH --time=3:00:00 
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=4G 

module load singularity 

singularity run \
--bind /data/DNU \
/data/DNU/liza/singularity_imgs/freesurfer_v7.1.1.sif \
/data/DNU/liza/data/XXY/Nifti \
/data/DNU/liza/data/XXY/Nifti/derivatives/Freesurfer \
group2 \
--participant_label $(xargs --arg-file=subs_with_t1w.txt echo) \
--measurements area volume thickness thicknessstd meancurv gauscurv foldind curvind \
--license_file "/data/DNU/liza/license.txt" \
--skip_bids_validator


# /usr/local/apps/freesurfer/7.1.1/license.txt
