#!/usr/bin/env python3
-*- coding: utf-8 -*-
"""
Created on Thu Jan 14 12:50:38 2021

@author: UM-AD\sm2hm
"""
import numpy as np
import nibabel as nib
import tensorflow as tf
from nilearn.input_data import NiftiMapsMasker
from nilearn import datasets

from keras.models import Model, Sequential
from keras.layers import Input, Dense
from keras.layers import LSTM, GRU, Dropout
from keras import optimizers
from keras.utils import plot_model
from keras import utils
from sklearn.metrics import roc_curve
from sklearn.model_selection import train_test_split
import pandas as pd
import scipy.io
from nilearn import input_data
from keras.regularizers import l2

smith_atlas = datasets.fetch_atlas_smith_2009()
smith_atlas_rs_networks = smith_atlas.rsn70
masker = NiftiMapsMasker(maps_img=smith_atlas_rs_networks,  
                         standardize=True, 
                         memory='nilearn_cache', 
                         verbose=0)

all_subjects_data=[]

data = open('/media/12TB/DBD_Preprocesssed/Subjects_fmri.txt', 'r').read().splitlines()
img_data = []
for i, x in enumerate(data):
    img = nib.load('/media/12TB/DBD_Preprocesssed/fMRI/data/' + x + '.nii')
        
    time_series = spheres_masker.fit_transform(img)
    all_subjects_data.append(time_series)

    

max_len_image=386
all_subjects_data_reshaped=[]
for subject_data in all_subjects_data:
  Padding
  N= max_len_image-len(subject_data)
  padded_array=np.pad(subject_data, ((0, N), (0,0)), 
                      'constant', constant_values=(0))
  subject_data=padded_array
  subject_data=np.array(subject_data)
  subject_data.reshape(subject_data.shape[0],subject_data.shape[1],1)
  all_subjects_data_reshaped.append(subject_data)


    