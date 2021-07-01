#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Jan 21 20:24:21 2021

@author: UM-AD\sm2hm
"""
import numpy as np
import os
import nibabel as nib
std_mask = nib.load('/media/12TB/DBD/bin_std.nii.gz')
data = open('/media/12TB/DBD/subject_list.txt', 'r').read().splitlines()
a = np.empty([91,109,91,len(data)])                  
for i, x in enumerate(data):
    os.system('fast /media/12TB/DBD/' + x + '/ses-baselineYear1Arm1/antsreg.nii.gz')
    os.system('fslmerge -t /media/12TB/DBD/' + x + '/ses-baselineYear1Arm1/seg_ants /media/12TB/DBD/' + x + '/ses-baselineYear1Arm1/antsreg_pve_0.nii.gz /media/12TB/DBD/' + x + '/ses-baselineYear1Arm1/antsreg_pve_1.nii.gz /media/12TB/DBD/' + x + '/ses-baselineYear1Arm1/antsreg_pve_2.nii.gz ')