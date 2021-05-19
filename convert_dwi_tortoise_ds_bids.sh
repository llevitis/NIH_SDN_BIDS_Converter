#!/bin/bash 

#==========================================================
# CHECK INPUTS
#==========================================================
dicom_dir=$1
dwi_dicom_dir=$2
sub=$3
ses=$4
bids_dir=$5

# for each subject, copy only the dwi data to a separate directory
# copy over the gradients file

dwi_dicom_sub=${dwi_dicom_dir}/sub-${sub}
dicom_readme=${dicom_dir}/sub-${sub}/ses-${ses}/*/README-Study.txt
g01_num=`cat ${dicom_readme} | grep "edti_cdiflist08_g01" | cut -d " " -f 3 | cut -d ":" -f 2`
g02_num=`cat ${dicom_readme} | grep "edti_cdiflist08_g02" | cut -d " " -f 3 | cut -d ":" -f 2`
g03_num=`cat ${dicom_readme} | grep "edti_cdiflist08_g03" | cut -d " " -f 3 | cut -d ":" -f 2`
g01_dicom_dir=${dicom_dir}/sub-${sub}/ses-${ses}/*/${g01_num}
g02_dicom_dir=${dicom_dir}/sub-${sub}/ses-${ses}/*/${g02_num}
g03_dicom_dir=${dicom_dir}/sub-${sub}/ses-${ses}/*/${g03_num}
gradients_file=${dwi_dicom_dir}/cdiflist08

if [ -f $dicom_readme ]
then
    g01_num=`cat ${dicom_readme} | grep "edti_cdiflist08_g01" | cut -d "," -f 3 | cut -d ":" -f 2`
    g02_num=`cat ${dicom_readme} | grep "edti_cdiflist08_g02" | cut -d "," -f 3 | cut -d ":" -f 2`
    g03_num=`cat ${dicom_readme} | grep "edti_cdiflist08_g03" | cut -d "," -f 3 | cut -d ":" -f 2`
    g01_dicom_dir=${dicom_dir}/sub-${sub}/ses-${ses}/*/${g01_num}
    g02_dicom_dir=${dicom_dir}/sub-${sub}/ses-${ses}/*/${g02_num}
    g03_dicom_dir=${dicom_dir}/sub-${sub}/ses-${ses}/*/${g03_num}
    gradients_file=${dwi_dicom_dir}/cdiflist08
    mkdir -p $dwi_dicom_sub
    mkdir -p $dwi_dicom_sub/dicom
    mkdir $dwi_dicom_sub/dicom/g01_dicom_dir
    mkdir $dwi_dicom_sub/dicom/g02_dicom_dir
    mkdir $dwi_dicom_sub/dicom/g03_dicom_dir
    ln -s $g01_dicom_dir/* $dwi_dicom_sub/dicom/g01_dicom_dir
    ln -s $g02_dicom_dir/* $dwi_dicom_sub/dicom/g02_dicom_dir
    ln -s $g03_dicom_dir/* $dwi_dicom_sub/dicom/g03_dicom_dir
    ln -s $gradients_file $dwi_dicom_sub/cdiflist08

    # run tortoise --> get the mri_ap_proc and mri_pc_proc
    ImportDICOM -i $dwi_dicom_sub/dicom -g $dwi_dicom_sub/cdiflist08 -b 1100

    # use tortoise to convert the bmtxt to bvals and bvecs 
    TORTOISEBmatrixToFSLBVecs $dwi_dicom_sub/dicom_proc/dicom.bmtxt

    # gzip the Nifti files

    gzip $dwi_dicom_sub/dicom_proc/dicom.nii

    if [ ! -x $bids_dir/sub-${sub}/ses-${ses}/dwi ]
    then 
        mkdir $bids_dir/sub-${sub}/ses-${ses}/dwi
    else
        echo "BIDS DWI dir already exists"
    fi
    # copy the new bvec, bval, and nii files to the BIDS directory 
    cp $dwi_dicom_sub/dicom_proc/dicom.bvecs $bids_dir/sub-${sub}/ses-${ses}/dwi/sub-${sub}_ses-${ses}_dwi.bvec
    cp $dwi_dicom_sub/dicom_proc/dicom.bvals $bids_dir/sub-${sub}/ses-${ses}/dwi/sub-${sub}_ses-${ses}_dwi.bval
    cp $dwi_dicom_sub/dicom_proc/dicom.nii.gz $bids_dir/sub-${sub}/ses-${ses}/dwi/sub-${sub}_ses-${ses}_dwi.nii.gz
    echo "New Nifti, bvec, and bval files have been copied over"
else
    echo "sub-${sub} has a differently named README file directory"
fi
