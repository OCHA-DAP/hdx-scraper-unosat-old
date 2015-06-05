#!/bin/bash

#
# Running the scraper.
#
R/bin/Rscript scripts/R/scraper.R

#
# Registering the datasets on HDX.
#
source venv/bin/activate
python scripts/hdx_register/