function EEGanalysis(name)
    
    %% read modeled prediction errors
    DATA = readtable(fullfile(fileparts(fileparts(pwd)),'Data_Processed',['subject_' name],['PE2_Heir_' name '.csv']));    
    Trial.fastPE = table2array(DATA(:,2));
    Trial.slowPE = table2array(DATA(:,3));
    if iscell(Trial.fastPE); ind_na = cellfun(@(x)strcmp(x,'NA'),Trial.fastPE); Trial.fastPE(ind_na) = {NaN}; Trial.fastPE = cellfun(@str2double,Trial.fastPE); end
    if iscell(Trial.slowPE); ind_na = cellfun(@(x)strcmp(x,'NA'),Trial.slowPE); Trial.slowPE(ind_na) = {NaN}; Trial.slowPE = cellfun(@str2double,Trial.slowPE); end
    

    %% read trial data
    filename = fullfile(fileparts(fileparts(pwd)),'Data_Raw',['subject_' name],[name '_schedule.db']);
    db = sqlite(filename);
    temp = cell2mat(fetch(db, 'SELECT feedback_time, feedback FROM trials WHERE choice_time IS NOT NULL AND block < 1000 AND stim1>17 AND stim2>17'));
    Trial.feedback = temp(:,2);
    Trial.feedbackTimes = temp(:,1);
    db.close;
    
    %%correspondence check
    if any(isnan(Trial.fastPE(Trial.feedback==1))) || any(isnan(Trial.slowPE(Trial.feedback==1))) || any(~isnan(Trial.fastPE(Trial.feedback==0)) & Trial.fastPE(Trial.feedback==0)~=0) || any(~isnan(Trial.slowPE(Trial.feedback==0)) & Trial.slowPE(Trial.feedback==0)~=0)
        error('Incompatibility');
    end
    
    %% isolate feedback trials
    Trial.feedbackTimes = Trial.feedbackTimes(Trial.feedback==1); 
    Trial.fastPE = Trial.fastPE(Trial.feedback==1);
    Trial.slowPE = Trial.slowPE(Trial.feedback==1);
    
    %% read EEG and remove trials with NaN
    [EEG, sampling_rate] = readEEG(name);
    epoch_data = Utilities.epoch(EEG.times, EEG.data, Trial.feedbackTimes, 500, 1500, sampling_rate);
    ind_na = any(any(isnan(epoch_data),2),3);
    epoch_data = epoch_data(~ind_na,:,:);
    TF = EEGtimefreq(epoch_data, sampling_rate);
    TF.fastPE = Trial.fastPE(~ind_na);
    TF.slowPE = Trial.slowPE(~ind_na);       
    TF.times = Trial.feedbackTimes(~ind_na);       
    
    %% decode
    [Slow.decodability, Slow.pval, Slow.predicted, Slow.regs] = EEGdecode(TF.slowPE, zscore(TF.data));
    [Fast.decodability, Fast.pval, Fast.predicted, Fast.regs] = EEGdecode(TF.fastPE, zscore(TF.data));
    Slow.times = TF.times;
    Fast.times = TF.times;
    save(fullfile(fileparts(fileparts(pwd)),'Data_Processed',['subject_' name],'PE_decoding'),'Slow','Fast');
    Slow
    Fast
end
    