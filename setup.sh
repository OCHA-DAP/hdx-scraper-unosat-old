#!/bin/bash

# Simple script to downlaod and
# set-up the SW folder with the necessary
# scripts.

# Compiling R.3.1
cd ~
wget 'http://cran.r-project.org/src/base/R-3/R-3.1.1.tar.gz'
tar -xvf R-3.1.1.tar.gz
mv R-3.1.1 R
cd R
./configure
make

# Creating Python's virtual env
cd ~
virtualenv venv