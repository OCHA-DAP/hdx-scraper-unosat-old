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

# Compiling ImageMagick
cd ~
wget http://ftp.de.debian.org/debian/pool/main/i/imagemagick/imagemagick_6.8.9.9-5.debian.tar.xz
tar -xvf imagemagick_6.8.9.9-5.debian.tar.xz
mv debian imagemagick
cd $HOME
export MAGICK_HOME="$HOME/imagemagick"
export PATH="$MAGICK_HOME/bin:$PATH"
LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+$LD_LIBRARY_PATH:}$MAGICK_HOME/lib"
export LD_LIBRARY_PATH

# Creating Python's virtual env
cd ~
virtualenv venv