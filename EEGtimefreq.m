function TF = EEGtimefreq(data, sampling_rate)

    addpath('fieldtrip-20191019');
    ft_defaults;
    freqs = 1:4:30; 

    ftdata.label = {'channel'};
    ftdata.fsample = sampling_rate;
    ftdata.trial = cellfun(@(x)permute(x, [3 2 1]), mat2cell(data, ones(size(data,1),1),size(data,2), 4)','UniformOutput',false);
    ftdata.time = mat2cell(repmat(-0.5:1/sampling_rate:1.5,[length(ftdata.trial),1]),ones(size(data,1),1),513)';
    ftdata.sampleinfo = [];
    ftdata.label = {'EEG1','EEG2','EEG3','EEG4'};

    cfg              = [];
    cfg.output       = 'pow';
    cfg.method       = 'mtmconvol';
    cfg.taper        = 'hanning';
    cfg.foi          = freqs;
    cfg.t_ftimwin    = 4./cfg.foi;  
    cfg.toi          = 'all';            
    cfg.keeptrials = 'yes';

    pow = ft_freqanalysis(cfg,ftdata);
    TF.data = permute(pow.powspctrm, [1 2 4 3]);
    TF.data = reshape(TF.data, [size(TF.data,1), size(TF.data,2)*size(TF.data,3)*size(TF.data,4)]);

    TF.data = TF.data(:,mean(isnan(TF.data),1)<0.5);
    TF.data = Utilities.downsample(TF.data,sampling_rate/30);
    
end



