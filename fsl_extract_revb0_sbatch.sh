#!/bin/bash

#SBATCH --array=1-90
#SBATCH --time=1:00:00

module load fsl

# extract subjects
SUBJECT=$( sed "${SLURM_ARRAY_TASK_ID}q;d" /data/DNU/liza/data/XXY/demo_data/XXY_3TC_PseudoGUIDs.txt )

./fsl_extract_revb0.sh /data/DNU/liza/data/XXY/Nifti ${SUBJECT} v01
