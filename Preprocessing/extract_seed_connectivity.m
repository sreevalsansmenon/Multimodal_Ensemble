clc
clear
addpath('/media/8TB/Softwares/spm12/')
load('Subject_Pool.mat')
Subjects = [Control_Subjects ;DBD_Subjects];
mask_files = dir('/media/12TB/DBD/Main_Regions//*.nii');

for i=1:1100
    tic
    if i<551
        file = ['/media/12TB/DBD_Preprocesssed/fMRI/Control/' char(Subjects(i)) '.nii'];
    else
        file = ['/media/12TB/DBD_Preprocesssed/fMRI/DBD/' char(Subjects(i)) '.nii'];
    end
    parfor n=1:size(mask_files,1)
        T(:,n)=rex(file,[mask_files(n).folder filesep mask_files(n).name],'select_clusters',0);
    end
    if sum(sum(T==0))>1
        Control_Subjects(i)
    end
    data = SCA(T,file);
    if sum(isinf(data(:)))>0
        i
    elseif sum(isnan(data(:)))>0
        i
    end
    save(['/media/12TB/DBD_Preprocesssed/fMRI/Static/static_' char(Subjects(i)) '.mat'],'data');
    clear T Data
    toc
end