%% Program by Sreevalsan S. Menon (sm2hm@mst.edu)

clc;clear;close all
% load('t1w_final.mat'); % Load t1w data
% load('fmri_data.mat'); % Load fmri data
load('dwi_data.mat')    % Load dwi data
Y = categorical([ones(1,550) 2*ones(1,550)]); % create categorical output
rng('default')          % For reproducibility
r =randperm(numel(Y));  % random permute the data
X = data(:,:,:,:,r); clear data % Create input data variable X
Y = Y(r);               % Shuffle Y
c = cvpartition(numel(Y),'KFold',10);   % Create 10 fold cross validation

for i=1:10  % loop over 10 folds
    % Call the moule of choice
%     t1w_custom(X(:,:,:,:,training(c,i)),Y(training(c,i)),X(:,:,:,:,test(c,i)),Y(test(c,i)),i)
%     fmri_custom(X(:,:,:,:,training(c,i)),Y(training(c,i)),X(:,:,:,:,test(c,i)),Y(test(c,i)),i)
    dwi_custom(X(:,:,:,:,training(c,i)),Y(training(c,i)),X(:,:,:,:,test(c,i)),Y(test(c,i)),i)
end

 