#!/bin/bash

#
# Downloading and compiling R.3.1.1
#
cd ~
wget 'http://cran.r-project.org/src/base/R-3/R-3.1.1.tar.gz'
tar -xvf R-3.1.1.tar.gz
mv R-3.1.1 R
cd R
./configure
make
cd ~
rm R-3.1.1.tar.gz

#
# Installing Python dependencies.
#
cd ~
virtualenv venv
pip install -r requirements.txt