clc; clear; close all

for i=1:10
    load(['fmri_' num2str(i) '.mat'],'YTest','YPred')
    fmri_accuracy(i) = sum(categorical(str2double(YPred))==YTest')/numel(YTest);
    
    prediction(:,1) = categorical(str2double(YPred));
    tp = sum((double(string(YPred)) == 1) & (double(YTest') == 1));
    fp = sum((double(string(YPred)) == 1) & (double(YTest') == 2));
    fn = sum((double(string(YPred)) == 2) & (double(YTest') == 1));
    tn = sum((double(string(YPred)) == 2) & (double(YTest') == 2));
    
    sensitivity_fmri(i) = tp/(tp + fn);  
    specificity_fmri(i) = tn/(tn + fp);  
    sen = tp/(tp + fn); 
    ppv = tp/(tp+fp);
    F1_fmri(i) = (2 * sen * ppv) / (sen + ppv);
    
    load(['dwi_' num2str(i) '.mat'], 'YTest','YPred')
    dwi_accuracy(i) = sum(categorical(str2double(YPred))==YTest')/numel(YTest);
    prediction(:,2) = categorical(str2double(YPred));
    tp = sum((double(string(YPred)) == 1) & (double(YTest') == 1));
    fp = sum((double(string(YPred)) == 1) & (double(YTest') == 2));
    fn = sum((double(string(YPred)) == 2) & (double(YTest') == 1));
    tn = sum((double(string(YPred)) == 2) & (double(YTest') == 2));
    
    sensitivity_dwi(i) = tp/(tp + fn);  
    specificity_dwi(i) = tn/(tn + fp);  
    sen = tp/(tp + fn); 
    ppv = tp/(tp+fp);
    F1_dwi(i) = (2 * sen * ppv) / (sen + ppv);
    ppv_dwi(i) = sum((double(YTest') == 1))/numel(YTest);

    
    load(['t1w_' num2str(i) '.mat'],'YTest','YPred')
    t1w_accuracy(i) = sum(categorical(str2double(YPred))==YTest')/numel(YTest);
    prediction(:,3) = categorical(str2double(YPred));
    tp = sum((double(string(YPred)) == 1) & (double(YTest') == 1));
    fp = sum((double(string(YPred)) == 1) & (double(YTest') == 2));
    fn = sum((double(string(YPred)) == 2) & (double(YTest') == 1));
    tn = sum((double(string(YPred)) == 2) & (double(YTest') == 2));
    
    sensitivity_t1w(i) = tp/(tp + fn);  
    specificity_t1w(i) = tn/(tn + fp);  
    sen = tp/(tp + fn); 
    ppv = tp/(tp+fp);
    F1_t1w(i) = (2 * sen * ppv) / (sen + ppv);
    
    YPred = mode(prediction(:,1:3),2);
    max_vote_accuracy(i) = sum(YPred==YTest')/numel(YTest);
    
    tp = sum((double(string(YPred)) == 1) & (double(YTest') == 1));
    fp = sum((double(string(YPred)) == 1) & (double(YTest') == 2));
    fn = sum((double(string(YPred)) == 2) & (double(YTest') == 1));
    tn = sum((double(string(YPred)) == 2) & (double(YTest') == 2));
    
    sensitivity_ens(i) = tp/(tp + fn);  
    specificity_ens(i) = tn/(tn + fp);  
    sen = tp/(tp + fn); 
    ppv = tp/(tp+fp);
    F1_ens(i) = (2 * sen * ppv) / (sen + ppv);
    ppv_ens(i) = sum((double(YTest') == 1))/numel(YTest);
    clear prediction
end

display(['The mean accuracy for fmri resting prediction is : ' num2str(mean(fmri_accuracy)*100)])
display(['The mean accuracy for dwi prediction is : ' num2str(mean(dwi_accuracy)*100)])
display(['The mean accuracy for t1w prediction is : ' num2str(mean(t1w_accuracy)*100)])
display(['The mean accuracy for ensemble prediction is : ' num2str(mean(max_vote_accuracy)*100)])


