!#/bin/bash 

docker run --rm -it -v /Users/levitise2/code/test_bids_conversion:/base nipy/heudiconv:latest -d /base/data/xxy_dicoms/{subject}/mr_*/*.dcm -s 00661 -o /base/NIH_SDN_BIDS_Heudiconv/ -f /base/NIH_SDN_BIDS_Converter/heuristic.py -c dcm2niix -b
