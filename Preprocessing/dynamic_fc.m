clc
clear
load('smith_data_timeseries.mat', 'data')

uppertriangle=find(triu(ones(70),1));                       % Finding the Upper Diagonal Elements Index
% Bandpass filter settings
TR=0.72;                                                    % Temporal resolution
fnq=1/(2*TR);                                               % Nyquist frequency
flp = 1/(60*1);                                             % lowpass frequency of filter (Hz)
fhi = 0.15;                                                 % highpass
Wn=[flp/fnq fhi/fnq];                                       % butterworth bandpass non-dimensional frequency
k=2;                                                        % 2nd order butterworth filter
[bfilt,afilt]=butter(k,Wn);                                 % construct the filter
clear fnq flp fhi Wn k                                      % Clear workspace
windowsize=85;
for s=1:size(data,1)                                    % Loop for saving the primary data for comparison
    t=1;i=1;                                                % Initialiaztion of Variables
    signaldata = squeeze(data(s,:,:));
    signaldata=double(detrend(signaldata));                         % Normalize the data
    signaldata=filtfilt(bfilt,afilt,signaldata);            % Filter the signaldata
    while t+windowsize<=376                              % Loop to perform window analysis
        dfc=real(Correlation(zscore(signaldata(t:t+windowsize-1,:)')',1,'corr',windowsize));  % Finding Dynamic FC matrix over window length w
        wdfc(s,i,:)=dfc(uppertriangle);                     % Saving the upper triangular elements of DFC
        i=i+1;t=t+5;                                        % Incrementing Variables
    end
end

