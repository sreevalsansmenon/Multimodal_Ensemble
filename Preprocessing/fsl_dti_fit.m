fold = dir('sub*');
parfor i=1:size(fold,1)
    cd([fold(i).folder filesep fold(i).name '/ses-baselineYear1Arm1/dwi/'])
    kk=dir('*.nii');
    for j=1:size(kk,1)
        system(['3dAutomask -prefix mask_' kk(j).name '.gz ' kk(j).name ])
        system(['dtifit -k ' kk(j).name ' -o dti_' extractBefore(kk(j).name,'_ses-') ' -m mask_' kk(j).name '.gz -r ' extractBefore(kk(j).name,'.nii') '.bvec -b ' extractBefore(kk(j).name,'.nii') '.bval'])
    end
end