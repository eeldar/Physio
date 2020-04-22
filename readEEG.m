function [EEG, sampling_rate] = readEEG(name)   
    sampling_rate = 256.03; 
    
    filename = fullfile(fileparts(fileparts(pwd)),'Data_Processed',['subject_' name],[name '_EEG.mat']);
    if exist(filename, 'file') 
        load(filename);
    else
        %% read from sqlite database
        dbname = fullfile(fileparts(fileparts(pwd)),'Data_Raw',['subject_' name],[name '_physio.db']);
        db = sqlite(dbname);
        DATA = fetch(db, 'SELECT recording_time,EEG1,EEG2,EEG3,EEG4,ISGOOD1,ISGOOD2,ISGOOD3,ISGOOD4 FROM EEG_muse ORDER BY recording_time ASC');
        db.close();

        if any(ischar(DATA{1,1})); EEG.times = cellfun(@str2double,DATA(:,1));
        else EEG.times = cellfun(@double,DATA(:,1));
        end
        EEG.data(:,1) =  cellfun(@str2double,DATA(:,2));
        EEG.data(:,2) =  cellfun(@str2double,DATA(:,3));
        EEG.data(:,3) =  cellfun(@str2double,DATA(:,4));
        EEG.data(:,4) =  cellfun(@str2double,DATA(:,5));
        EEG.isgood(:,1) = cellfun(@str2double,DATA(:,6));
        EEG.isgood(:,2) = cellfun(@str2double,DATA(:,7));
        EEG.isgood(:,3) = cellfun(@str2double,DATA(:,8));
        EEG.isgood(:,4) = cellfun(@str2double,DATA(:,9));
        clear DATA
        
        %% convert isgood to logical
        EEG.isgood = logical(EEG.isgood==1 | EEG.isgood==2);
        
        %% infer real times of samples
        real_recording_time = Utilities.createRealTime(double(EEG.times), sampling_rate);
        EEG.times = Utilities.correctRealTime(real_recording_time, double(EEG.times), sampling_rate);
        
        %%  save
        save(filename, 'EEG','sampling_rate');
    end
    
    
    %% remove zero values and those that are more than 5 SDs from median
    for channel = 1:4
        indGood = EEG.isgood(:,channel);
        mn = nanmean(EEG.data(indGood,channel));
        sd = nanstd(EEG.data(indGood,channel));
        nogood = EEG.data(:,channel) > mn + 5*sd | EEG.data(:,channel) < mn - 5*sd | EEG.data(:,channel)<=0;
        EEG.data(nogood,channel) = nan;
    end
       
end
