#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov 13 10:46:04 2020

@author: UM-AD\sm2hm
"""
import os
import random
import tensorflow as tf
from E2E_conv import *
from sklearn.model_selection import KFold, StratifiedKFold
from keras.models import Sequential
from keras.layers import Convolution2D
from keras.layers import Dense, Dropout, Flatten
from keras.layers import LeakyReLU
from keras import optimizers, callbacks, regularizers, initializers
from E2E_conv import *
import numpy as np
from keras.utils import to_categorical
from sklearn.model_selection import StratifiedKFold
from sklearn.metrics import accuracy_score
from scipy.io import loadmat
from numpy import inf
from keras.optimizers import SGD
from keras.callbacks import ModelCheckpoint
import pandas as pd
from sklearn.model_selection import StratifiedKFold
from keras.models import load_model


tf.get_logger().setLevel('ERROR')
data_dict = loadmat('smith_connectivity.mat')
X= np.reshape(np.array(data_dict['X']),(1100,70,70,1))
X[X == inf] = 0
y = pd.get_dummies(np.concatenate((np.zeros(549+1),np.ones(546+4))))

def create_model():
    momentum = 0.9
    lr = 0.001
    decay = 0.0005
    reg = regularizers.l2(decay)
    kernel_init = initializers.he_uniform()
    model = Sequential()
    model.add(E2E_conv(2,4,(2,70),kernel_regularizer=reg,input_shape=(70,70,1),data_format="channels_last"))
    model.add(LeakyReLU(alpha=0.33))
    # model.add(E2E_conv(2,32,(2,90),kernel_regularizer=reg,input_shape=(90,90,1),data_format="channels_last"))
    # model.add(LeakyReLU(alpha=0.33))
    # model.add(E2E_conv(2,64,(2,90),kernel_regularizer=reg,input_shape=(90,90,1),data_format="channels_last"))
    # model.add(LeakyReLU(alpha=0.33))
    model.add(Convolution2D(4,(1,70),kernel_regularizer=reg,data_format="channels_last"))
    model.add(LeakyReLU(alpha=0.33))
    model.add(Flatten())
    model.add(Dropout(0.8))
    model.add(Dense(2,activation = "softmax",kernel_regularizer=reg,kernel_initializer=kernel_init))
    model.add(Flatten())
    model.compile(optimizer=SGD(nesterov=True,lr=lr), loss='categorical_crossentropy', metrics=['accuracy'])
    return model
    
kfold = StratifiedKFold(n_splits=10, shuffle=True, random_state=5)
i=0
cvscores = []
prediction = []
actual_out=[]
for train, test in kfold.split(X,np.concatenate((np.zeros(550),np.ones(550)))):
    # checkpoint
    # i+=1
    # filepath="weights-" + str(i) + ".hdf5"
    # model = None
    # model = create_model()
    # model.load_weights(filepath)
    # prediction.append(model.predict_classes(X[test]))
    # actual_out.append(y.loc[test])
    filepath="weights-" + str(i) + "-{val_accuracy:.2f}-{model_accuracy:.2f}.hdf5"
    checkpoint = ModelCheckpoint(filepath, monitor='val_accuracy', verbose=1, save_best_only=True, mode='max')
    callbacks_list = [checkpoint]
    model = None
    model = create_model()
    history = model.fit(X[train], y.loc[train], validation_data=(X[test], y.loc[test]),callbacks=callbacks_list, batch_size=128,epochs=1000)
