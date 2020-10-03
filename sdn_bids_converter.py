import os
import logging
import re
from subprocess import call
import json
from argparse import ArgumentParser 

SCAN_EXPR = """\
^(?P<rec_ex>PU:)?\
(?P<modality>[a-z]+)?\
(-(?P<label>[a-zA-Z0-9]+))?\
(_task-(?P<task>[a-zA-Z0-9]+))?\
(_acq-(?P<acq>[a-zA-Z0-9]+))?\
(_ce-(?P<ce>[a-zA-Z0-9]+))?\
(_rec-(?P<rec>[a-zA-Z0-9]+))?\
(_dir-(?P<dir>[a-zA-Z0-9]+))?\
(_run-(?P<run>[a-zA-Z0-9]+))?\
(_echo-(?P<echo>[0-9]+))?\
"""

def parse_json(json_file):
    """
    Parse json file.
    Parameters
    ----------
    json_file: json
        JSON file containing information about which subjects/sessions/scans to
        download from which project and where to store the files.
    JSON Keys
    ---------
    destination: string
        Directory to construct the BIDS structure
    scan_dict: dictionary
        a dictionary/hash table where the keys are the scan names on xnat
        and the values are the reproin style scan names
    session_labels: list
        (optional) (non-BIDS) If you want to replace the names of the sessions
        on xnat with your own list of scans.
    scan_labels: list
        (optional) a list of the scans you want to download (if you don't want to
        download all the scans).
    Returns
    -------
    input_dict:
        A dictionary containing the parameters specified in the JSON file
    """
    import json
    with open(json_file) as json_input:
        input_dict = json.load(json_input)
        # print(str(input_dict))
    mandatory_keys = ['destination']
    optional_keys = ['session_labels', 'subjects', 'scan_labels',
                     'scan_dict', 'num_digits', 'sub_dict', 'sub_label_prefix']
    total_keys = mandatory_keys+optional_keys
    # print("total_keys: "+str(total_keys))
    # are there any inputs in the json_file that are not supported?
    extra_inputs = list(set(input_dict.keys()) - set(total_keys))
    if extra_inputs:
        logging.warning('JSON spec key(s) not supported: %s' % str(extra_inputs))

    # are there missing mandatory inputs?
    missing_inputs = list(set(mandatory_keys) - set(input_dict.keys()))
    if missing_inputs:
        raise KeyError('option(s) need to be specified in input file: '
                       '%s' % str(missing_inputs))

    return input_dict
    
def extract_mr_dir_description(readme_path): 
    readme_dict_orig = {} 
    # creating dictionary 
    with open(readme_path) as fh: 
        for line in fh: 
            # reads each line and trims of extra the spaces  
            # and gives only the valid words 
            command, description = line.strip().split(None, 1) 
            readme_dict_orig[command] = description.strip() 
    mr_dir_dict = {}
    for key in readme_dict_orig.keys(): 
        if "Series" in key: 
            mr_dir = key.split(":")[1].split(",")[0]
            metadata = [x.lstrip() for x in readme_dict_orig[key].split(",")]
            description = metadata[2].split(")")[-1]
            mr_dir_dict[mr_dir] = description
            
    # fix the values for the multiecho files
            
    i=1
    j=1
    for key in mr_dir_dict.keys(): 
        if mr_dir_dict[key] == "me_mp_rage_1mm_promo": 
            mr_dir_dict[key] = "me_mp_rage_1mm_promo_echo-{0}".format(i) 
            i += 1
        elif mr_dir_dict[key] == "orig_me_mp_rage_1mm_promo": 
            mr_dir_dict[key] = "orig_me_mp_rage_1mm_promo_echo-{0}".format(j) 
            j += 1
    
    return mr_dir_dict
    
def main():

    parser = ArgumentParser()
    parser.add_argument("--bids_conversion_info",
                        help="Please pass the path to the bids conversion info JSON file.")
    results = parser.parse_args()
    bids_conversion_info = results.bids_conversion_info

    input_dict = parse_json(bids_conversion_info)
    scan_repl_dict = input_dict.get('scan_dict', None)
    nih_sdn_raw_dir = input_dict.get('nih_sdn_raw_dir', None)
    for sub_dir in os.listdir(nih_sdn_raw_dir): 
        sub_dir = os.path.join(nih_sdn_raw_dir, sub_dir)
        # session number
        i = 1
        subject = sub_dir.split("/")[-1].split("-")[1]
        for ses_dir in os.listdir(sub_dir):
            ses_dir = os.path.join(sub_dir, ses_dir)
            session = "v0" + str(i)
            mr_dir_dict = extract_mr_dir_description(os.path.join(ses_dir, "README-Study.txt"))
            mr_dir_dict['subject'] = subject
            mr_dir_dict['session'] = session           
            k=1
            j=1
            for key in mr_dir_dict.keys(): 
                if mr_dir_dict[key] == "me_mp_rage_1mm_promo": 
                    mr_dir_dict[key] = "me_mp_rage_1mm_promo_echo-{0}".format(k) 
                    k += 1
                elif mr_dir_dict[key] == "orig_me_mp_rage_1mm_promo": 
                    mr_dir_dict[key] = "orig_me_mp_rage_1mm_promo_echo-{0}".format(j) 
                    j += 1
            
            i += 1
            
            for mr_key in mr_dir_dict.keys():
                sub_name = 'sub-' + mr_dir_dict['subject'] 
                ses_name = 'ses-' + mr_dir_dict['session']
                scan = mr_dir_dict[mr_key]
                dest = input_dict['destination']
                if scan in scan_repl_dict.keys():
            #         print('{scan} is a part of dictionary'.format(scan=scan))
                    dcm_dir = os.path.join(ses_dir, mr_key)
                    bids_scan = scan_repl_dict[scan]
                    # PU:task-rest_bold -> PU_task_rest_bold
                    scan_fmt = re.sub(r'[^\w]', '_', scan)        
                    scan_pattern = re.compile(SCAN_EXPR)

                    scan_pattern_dict = re.search(scan_pattern, bids_scan).groupdict()

                    # build up the bids directory
                    bids_dir = os.path.join(dest, sub_name, ses_name, scan_pattern_dict['modality'])
            #         print(bids_dir)
                    if not os.path.isdir(bids_dir):
                        os.makedirs(bids_dir)

                    # name the bids file
                    fname = '_'.join([sub_name, ses_name])

                    bids_keys_order = ['task', 'acq', 'ce', 'rec', 'rec_ex', 'dir', 'run', 'echo']

                    for key in bids_keys_order:
                        label = scan_pattern_dict[key]
                        if label is not None:
                            if key == 'rec_ex':
                                key = 'rec'
                                label = 'pu'
                            fname = '_'.join([fname, key + '-' + label])

                    # add the label (e.g. _bold)
                    if scan_pattern_dict['label'] is None:
                        label = scan_pattern_dict['modality']
                    else:
                        label = scan_pattern_dict['label']

                    fname = '_'.join([fname, label])

            #         print('the dcm dir is {dcm_dir}'.format(dcm_dir=dcm_dir))
                    dcm2niix = 'dcm2niix -o {bids_dir} -f {fname} -z y -b y {dcm_dir}'.format(
                        bids_dir=bids_dir,
                        fname=fname,
                        dcm_dir=dcm_dir)
                    bids_outfile = os.path.join(bids_dir, fname + '.nii.gz')
                    print(bids_outfile)
                    if not os.path.exists(bids_outfile) or overwrite_nii:
                        call(dcm2niix, shell=True)
                    else:
                        print('It appears the nifti file already exists for {scan}'.format(scan=scan))

if __name__ == "__main__":
    main()