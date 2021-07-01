clc
clear
close all
% Set up FSL environment
setenv( 'FSLDIR', '/usr/local/fsl');
fsldir = getenv('FSLDIR');
fsldirmpath = sprintf('%s/etc/matlab',fsldir);
path(path, fsldirmpath);
clear fsldir fsldirmpath;

load('t1w_data.mat')
Y = categorical([ones(1,550) 2*ones(1,550)]);
rng('default') % For reproducibility
r =randperm(numel(Y));
data = data(:,:,:,:,r);
Y = Y(r);
c = cvpartition(numel(Y),'KFold',10);


for i=1:10
    load(['t1w_' num2str(i) '.mat']);
    X=data(:,:,:,:,test(c,i));
    lgraph = layerGraph(dlnet1);
    lgraph = removeLayers(lgraph, lgraph.Layers(end).Name);
    dlnet = dlnetwork(lgraph);
    softmaxName = 'softmax';
    featureLayerName = 'relu_f2';
    idx = (grp2idx(YTest)==1)'.*(YPred' == YTest);
    dldata1 = dlarray(single(X(:,:,:,:,logical(idx))),'SSSCB'); 
    parfor j=1:size(dldata1,5)
        [featureMap, dScoresdMap] = dlfeval(@gradcam, dlnet1, squeeze(dldata1(:,:,:,:,j)), softmaxName, featureLayerName, 1);
        gradcamMap = sum(featureMap .* sum(dScoresdMap, [1 2 3]), 4);
        gradcamMap_cv(:,:,:,j) = extractdata(gradcamMap);
    end
        gradcamMap_cv_all(:,:,:,i) = mean(gradcamMap_cv,4);
end

mask = niftiread('/usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz');
mask = double(mask);mask(mask>0)=1;
gradcamMap = mean(gradcamMap_cv_all,4);
gradcamMap = imresize3(gradcamMap, [91,109,91], 'Method', 'nearest').*mask;
gradcamMap = rescale(gradcamMap).*mask;
gradcamMap(gradcamMap>0.6)=1;
save_avw(gradcamMap,'t1w_cam.nii.gz','f',[2 2 2]);
system('/usr/local/fsl/bin/fslcpgeom /usr/local/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz savet1w_cam.nii.gz');