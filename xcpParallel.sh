#!/bin/bash
#SBATCH --array 1-227
#SBATCH --job-name xcp_engine
#SBATCH --cpus-per-task=16
#SBATCH --mem-per-cpu=4G
#SBATCH --time=12:00:00

module load xcpengine/1.2.3

LINE_NUM=$( expr $SLURM_ARRAY_TASK_ID + 1 )
LINE=$(awk "NR==$LINE_NUM" /data/DNU/liza/data/xxy_xcp_cohort_file.csv)
TEMP_COHORT=/data/DNU/liza/data/xxy_xcp_cohort_file.csv.${SLURM_ARRAY_TASK_ID}.csv
echo X,id0,id1,img > $TEMP_COHORT
echo $LINE >> $TEMP_COHORT

xcpEngine   -d /data/DNU/liza/data/fc-acompcor.dsn   -c ${TEMP_COHORT}   -o /data/DNU/liza/data/XXY/Nifti/derivatives/xcpOutput   -r /data   -i $TMPDIR

