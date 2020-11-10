#!/bin/bash 

#SBATCH --time=03:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G

module load mriqc/0.15.1
cd /data/DNU/liza/data/XXY

mriqc Nifti Nifti/derivatives/MRIQC group \
--n_procs 10 \
--mem_gb 8 \
--no-sub

