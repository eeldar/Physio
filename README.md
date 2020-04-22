# EEG analysis pipeline

### Requirements:  
 - MATLAB
 - Fieldtrip toolbox  (http://www.fieldtriptoolbox.org/)
 - libsvm  (https://www.csie.ntu.edu.tw/~cjlin/libsvm/)
 
 ### Instructions:  
 - Run *delete_duplicates_and_merge_physio(subject_name)* once to prepare SQLite files for analysis
 - Run *EEGanalysis(subject_name)*  to decode modelled reward prediction errors from EEG data
 
 ### Scripts:
 - *delete_duplicates_and_merge_physio.m* - prepares SQLite files for analysis
 - *EEGanalysis.m* - decode modelled reward prediction errors from EEG data
 - *readEEG.m* - loads subject's EEG data
 - *EEGtimefreq.m* - preforms timefrequency analysis on EEG data
 - *EEGdecode.m* - preforms cross-validated decoding 
 - *Utilities.m* - a class of helper functions
