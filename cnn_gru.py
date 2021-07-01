#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Apr 22 17:40:52 2021

@author: UM-AD\sm2hm
"""
from keras import backend as K
from keras.models import Model

import keras
import numpy as np
import pandas as pd
from tensorflow.keras import regularizers
from keras.models import Sequential
from keras.layers import Dense, Dropout, Activation, Flatten, Concatenate,Input
from keras.layers import Convolution1D, MaxPooling1D
from keras.utils import np_utils
from keras.layers.convolutional import Conv1D, AveragePooling1D
from keras.layers import GRU, LSTM, Dropout
from keras.layers.convolutional import MaxPooling1D
from keras.layers.embeddings import Embedding
from keras.preprocessing import sequence
from keras.preprocessing.text import Tokenizer
from keras.preprocessing.sequence import pad_sequences
from sklearn.model_selection import train_test_split
from sklearn.model_selection import StratifiedKFold
from keras.callbacks import ModelCheckpoint


all_subjects_data_reshaped = np.load('/media/12TB/DBD_Preprocesssed/data_timeseries_smith_atlas_idfc.npy')
y = pd.get_dummies(np.concatenate((np.zeros(549+1),np.ones(546+4))))

def create_model():
    inp = Input(shape=(all_subjects_data_reshaped.shape[1],all_subjects_data_reshaped.shape[2]))
    conv_1 = Convolution1D(16*2, 2, 1, padding="same", data_format='channels_last')(inp)
    conv_2 = Convolution1D(16*2, 4, 1, padding="same", data_format='channels_last')(inp)
    conv_3 = Convolution1D(16*2, 8, 1, padding="same", data_format='channels_last')(inp)
    
    out = Concatenate()([conv_1,conv_2,conv_3])
    model = Sequential()
    model.add(Model(inputs = inp, outputs=out))
    
    model.add(MaxPooling1D(pool_size=3,data_format='channels_first'))
    model.add(GRU(16*2,return_sequences=True))
    model.add(GRU(16*2,return_sequences=True))
    model.add(AveragePooling1D(all_subjects_data_reshaped.shape[1]))
    model.add(Flatten())
    model.add(Dropout(0.5))
    model.add(Dense(16*2,activation='relu',kernel_regularizer=regularizers.l1_l2(l1=1e-2, l2=1e-2)))
    model.add(Dropout(0.2))
    model.add(Dense(2,activation='sigmoid'))
    opt = keras.optimizers.Adam(learning_rate=0.001)
    model.compile(loss='binary_crossentropy',optimizer=opt,metrics=['accuracy'])
    return model

# model.summary()

# X_train, X_test, y_train, y_test = train_test_split(all_subjects_data_reshaped,y, test_size=0.1, random_state=2)


kfold = StratifiedKFold(n_splits=10, shuffle=True, random_state=5)
i=0
cvscores = []
for train, test in kfold.split(all_subjects_data_reshaped,np.concatenate((np.zeros(549+1),np.ones(546+4)))):
    # checkpoint
    i+=1
    filepath="idfc_weights-" + str(i) + "-{val_accuracy:.2f}-{accuracy:.2f}.hdf5"
    checkpoint = ModelCheckpoint(filepath, monitor='val_accuracy', verbose=1, save_best_only=True, mode='max')
    callbacks_list = [checkpoint]
    model = None
    model = create_model()
    history = model.fit(all_subjects_data_reshaped[train], y.loc[train], validation_data=(all_subjects_data_reshaped[test], y.loc[test]),callbacks=callbacks_list, batch_size=32,epochs=100)