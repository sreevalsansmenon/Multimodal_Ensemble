#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Mar  23 15:50:57 2020

@author: UM-AD\sm2hm
"""
import os
data = open('data.txt', 'r').read().splitlines()

for i, x in enumerate(data):
    if i%500 == 0:
        os.system('python /media/DATA/DATA4/nda_aws_token_generator-master/python/get_token_example.py')
    os.system(r'aws s3 cp ' + x + ' /media/DATA/DATA3/DBD_ABCD/ --profile NDA')
