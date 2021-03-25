#!/bin/sh

#SBATCH --cpus-per-task=4
#SBATCH --time=12:00:00

module load singularity 

nextflow -c /data/DNU/liza/code/tractoflow-2.1.1/singularity.conf run /data/DNU/liza/code/tractoflow-2.1.1/main.nf --bids  /data/DNU/liza/data/XXY/Nifti/ --dti_shells "DTI_SHELLS" --fodf_shells "FODF_SHELLS" -with-singularity /data/DNU/liza/singularity_imgs/tractoflow_2.1.1_650f776_2020-07-15.img --output_dir /data/DNU/liza/data/XXY/Nifti/derivatives/results/ -resume
