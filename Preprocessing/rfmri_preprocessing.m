clc
clear
Subjects = dir('sub-*');
parfor i=1:size(Subjects,1)
    if isfolder([Subjects(i).folder filesep Subjects(i).name filesep 'ses-baselineYear1Arm1' filesep 'anat'])==1
            cd([Subjects(i).folder filesep Subjects(i).name filesep 'ses-baselineYear1Arm1' filesep 'anat'])
            t1f=dir('*.nii');
            system(['/usr/local/fsl/bin/bet ' t1f(1).folder filesep t1f(1).name ' ' Subjects(i).folder filesep Subjects(i).name filesep 'ses-baselineYear1Arm1' filesep 'anat/' Subjects(i).name '_ses-baselineYear1Arm1_run-01_T1w_brain -R -f 0.5 -g 0']);
    end
    if isfile(['/media/DATA/DATA3/DBD_ABCD_Control/Preprocessed/' Subjects(i).name '.feat/report_reg.html'])==0
        if isfolder([Subjects(i).folder filesep Subjects(i).name filesep 'ses-baselineYear1Arm1' filesep 'func'])==1
            cd([Subjects(i).folder filesep Subjects(i).name filesep 'ses-baselineYear1Arm1' filesep 'func'])
            boldimage=dir('*.nii*');
            [~, vols]=system(['fslnvols ' boldimage(1).name]);
            fid = fopen('/media/DATA/DATA3/DBD_ABCD_Control/rfmri_design.fsf','rt');
            X = fread(fid) ;
            fclose(fid) ;
            Y = strrep(X, 'total_volume', vols) ;
            Y = strrep(Y, 'Subject', Subjects(i).name) ;
            Y = strrep(Y, 'bold_name', boldimage(1).name) ;
            fid2 = fopen('rfmri_design_pediatric.fsf','wt') ;
            fwrite(fid2,Y) ;
            fclose (fid2) ;
            system('feat rfmri_design_pediatric.fsf')
            c = ['/media/DATA/DATA3/DBD_ABCD_Control/Preprocessed/' Subjects(i).name '.feat/'];
            system(['applywarp --ref=' c '/reg/standard.nii.gz --in=' c '/filtered_func_data.nii.gz --warp=' c '/reg/example_func2standard_warp --out=' c '/filtered_func_data_mni.nii.gz']);
        end
    end
end