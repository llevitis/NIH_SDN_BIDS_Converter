#!/bin/bash

#====================================================================
# CHECK INPUTS
#====================================================================
bids_dir=$1
sub=$2
ses=$3

ap_scan="${bids_dir}/sub-${sub}/ses-${ses}/dwi/sub-${sub}_ses-${ses}_acq-AP_dwi.nii.gz"
pa_scan="${bids_dir}/sub-${sub}/ses-${ses}/dwi/sub-${sub}_ses-${ses}_acq-PA_dwi.nii.gz"
revb0_scan="${bids_dir}/sub-${sub}/ses-${ses}/dwi/sub-${sub}_ses-${ses}_acq-revb0_dwi.nii.gz"
nodif_scan="${bids_dir}/sub-${sub}/ses-${ses}/dwi/nodif.nii.gz"
nodif_PA_scan="${bids_dir}/sub-${sub}/ses-${ses}/dwi/nodif_PA.nii.gz"


fslroi $ap_scan $nodif_scan 0 1
fslroi $pa_scan $nodif_PA_scan 0 1
fslmerge -t $revb0_scan $nodif_scan $nodif_PA_scan

echo "${revb0_scan} has been created!"
rm $nodif_scan
rm $nodif_PA_scan
