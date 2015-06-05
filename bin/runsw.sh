#!/bin/bash

#
# Running the scraper.
#
~/R/bin/Rscript tool/scripts/R/scraper.R

#
# Registering the datasets on HDX.
#
cd ~
source venv/bin/activate
python tool/scripts/hdx_register/