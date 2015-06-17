#!/bin/bash

# Simple script to downlaod and
# set-up the SW folder with the necessary
# scripts.

# Creating Python's virtual env
# cd
virtualenv venv
source venv/bin/activate
pip install -r requirements.txt
