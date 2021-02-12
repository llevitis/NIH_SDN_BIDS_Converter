#!/bin/bash 

#==========================================================
# CHECK INPUTS
#==========================================================
dicom_dir=$1
dwi_dicom_dir=$2
sub=$3
ses=$4
bids_dir=$5

# for each subject, copy only the dwi data to a separate directory (find out if symlink is an alt)
# have to determine which series corresponds to AP and PA
# copy over the gradients file

dwi_dicom_sub=${dwi_dicom_dir}/sub-${sub}
dicom_readme=${dicom_dir}/sub-${sub}/ses-${ses}/*/README-Study.txt
ap_num=`cat ${dicom_readme} | grep "edti_2mm_cdif45_ap" | cut -d "," -f 1 | cut -d ":" -f 2`
pa_num=`cat ${dicom_readme} | grep "edti_2mm_cdif45_pa" | cut -d "," -f 1 | cut -d ":" -f 2`
ap_dicom_dir=${dicom_dir}/sub-${sub}/ses-${ses}/*/${ap_num}
pa_dicom_dir=${dicom_dir}/sub-${sub}/ses-${ses}/*/${pa_num}
gradients_file=${dicom_dir}/sub-${sub}/ses-${ses}/*/realtime/cdiflist45

if [ ! -x $dwi_dicom_sub ]
then
    mkdir -p $dwi_dicom_sub/dicom
    mkdir $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-AP_dwi
    mkdir $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-PA_dwi
    ln -s $ap_dicom_dir/* $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-AP_dwi
    ln -s $pa_dicom_dir/* $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-PA_dwi
    ln -s $gradients_file $dwi_dicom_sub/cdiflist45

    # run tortoise --> get the mri_ap_proc and mri_pc_proc
    ImportDICOM -i $dwi_dicom_sub/dicom -g $dwi_dicom_sub/cdiflist45 -b 1100

    # use tortoise to convert the bmtxt to bvals and bvecs 
    TORTOISEBmatrixToFSLBVecs $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-AP_dwi_proc/sub-${sub}_ses-${ses}_acq-AP_dwi.bmtxt
    TORTOISEBmatrixToFSLBVecs $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-PA_dwi_proc/sub-${sub}_ses-${ses}_acq-PA_dwi.bmtxt

    # gzip the Nifti files

    gzip $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-AP_dwi_proc/sub-${sub}_ses-${ses}_acq-AP_dwi.nii
    gzip $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-PA_dwi_proc/sub-${sub}_ses-${ses}_acq-PA_dwi.nii


    # copy the new bvec, bval, and nii files to the BIDS directory 
    for dir in AP PA
    do
        cp $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-${dir}_dwi_proc/sub-${sub}_ses-${ses}_acq-${dir}_dwi.nii.gz $bids_dir/sub-${sub}/ses-${ses}/dwi/sub-${sub}_ses-${ses}_acq-${dir}_dwi.nii.gz
        cp $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-${dir}_dwi_proc/sub-${sub}_ses-${ses}_acq-${dir}_dwi.bvals $bids_dir/sub-${sub}/ses-${ses}/dwi/sub-${sub}_ses-${ses}_acq-${dir}_dwi.bval
        cp $dwi_dicom_sub/dicom/sub-${sub}_ses-${ses}_acq-${dir}_dwi_proc/sub-${sub}_ses-${ses}_acq-${dir}_dwi.bvecs $bids_dir/sub-${sub}/ses-${ses}/dwi/sub-${sub}_ses-${ses}_acq-${dir}_dwi.bvec
    done

    echo "New Nifti, bvec, and bval files have been copied over"
else
    echo "Subject directory for sub-${sub} already exists in dwi_dicom"
fi
