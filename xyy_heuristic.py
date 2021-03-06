import os


def create_key(template, outtype=('nii.gz',), annotation_classes=None):
    if template is None or not template:
        raise ValueError('Template must be a valid format string')
    return template, outtype, annotation_classes


def infotodict(seqinfo):
    """Heuristic evaluator for determining which runs belong where

    allowed template fields - follow python string module:

    item: index within category
    subject: participant id
    seqitem: run number during scanning
    subindex: sub index within group
    """

    # data = create_key('run{item:03d}')
    # info = {data: []}
    # last_run = len(seqinfo)

    """
        The namedtuple `s` contains the following fields:

        * total_files_till_now
        * example_dcm_file
        * series_id
        * dcm_dir_name
        * unspecified2
        * unspecified3
        * dim1
        * dim2
        * dim3
        * dim4
        * TR
        * TE
        * protocol_name
        * is_motion_corrected
        * is_derived
        * patient_id
        * study_description
        * referring_physician_name
        * series_description
        * image_type
        """

    t1w = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_T1w')
    t2w = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_T2w')
    func_rest = create_key('sub-{subject}/{session}/func/sub-{subject}_{session}_task-rest_bold')
    dwi_ap = create_key('sub-{subject}/{session}/dwi/sub-{subject}_{session}_acq-AP_dwi')
    dwi_pa = create_key('sub-{subject}/{session}/dwi/sub-{subject}_{session}_acq-PA_dwi')
    t2star = create_key('sub-{subject}/{session}/dwi/sub-{subject}_{session}_T2star')
    t2w_fatsat = create_key('sub-{subject}/{session}/anat/sub-{subject}_{session}_acq-fatsat_T2w')
    
    info = {t1w: [], t2w: [], func_rest: [], dwi_ap: [], dwi_pa: [], t2star: [], t2w_fatsat: []}

    for idx, s in enumerate(seqinfo):
        if (s.example_dcm_file == 'mp_rage_1_mm-00001.dcm'):
            info[t1w].append(s.series_id)
        if ('edti_2mm_cdif45_AP' in s.series_description):
            info[dwi_ap].append(s.series_id)
        if ('edti_2mm_cdif45_PA' in s.series_description):
            info[dwi_pa].append(s.series_id)
        if (s.series_description == 'Sag CUBE T2'):
            info[t2w].append(s.series_id)
        if (s.series_description == 'ORIG Sag CUBE T2'):
            info[t2w_orig].append(s.series_id)
        if ('T2_1.7mm_fat_sat' in s.series_description): 
            info[t2w_fatsat].append(s.series_id)
        if (s.series_description == 'Reverse blip EPI 3mm iso'):
            info[t2star].append(s.series_id) 
        if (s.series_description == 'Resting EPI 3mm iso RS') and (s.dim3 == 12300):
            info[func_rest].append(s.series_id)
    return info
        


