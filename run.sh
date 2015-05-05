#!/bin/bash

# Running the scraper.
~/R/bin/Rscript ~/tool/code/scraper.R

# Registering the datasets on HDX.
source venv/bin/activate
python scripts/hdx_register/