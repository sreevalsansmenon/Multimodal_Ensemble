function out_roi = SCA(T,D)

% Set up FSL environment
setenv( 'FSLDIR', '/usr/local/fsl');
fsldir = getenv('FSLDIR');
fsldirmpath = sprintf('%s/etc/matlab',fsldir);
path(path, fsldirmpath);
clear fsldir fsldirmpath;

% Load BOLD dataset:
[img,dims] = read_avw(D);
img = reshape(img,dims(1)*dims(2)*dims(3),dims(4));

% Perform correlation:
out_roi = zeros(dims(1),dims(2),dims(3),size(T,2));
for i=1:size(T,2)
%     out = corr(T(:,i),img');
    out  = zeros(1,length(img));
    parfor jj = 1:size(img,1)
        out(1,jj) = partialcorr(T(:,i),img(jj,:)',img(~jj,:)');
    end
    out = reshape(out',dims(1),dims(2),dims(3),1);
    out(isnan(out)==1) = 0;
    % Perform r to z transform:
    out_roi(:,:,:,i) = 0.5*log((1+out)./(1-out));
end






% % Save output image:
% save_avw(out,c,'f',[2 2 2 1])
% system(['/usr/local/fsl/bin/fslcpgeom /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz ' c])