#!/usr/bin/python
# -*- coding: utf-8 -*-

import os
import sys
import requests
import yajl as json
import progressbar as pb

dir = os.path.split(os.path.split(os.path.realpath(__file__))[0])[0]
sys.path.append(dir)

from termcolor import colored as color
from utilities.prompt_format import item as I

def FetchConfig(j = 'dev'):
  '''Fetching configuration from local JSON file.'''

  j = j + '.json'

  data_path = os.path.split(dir)[0]

  try:
    j = os.path.join(data_path, 'config', j)
    with open(j) as json_file:    
      data = json.load(json_file)

  except Exception as e:
    print "Could not load configuration."
    print e
    return False

  #
  # Perform basic quality checks.
  #
  if len(data['hdx_key']) is not 36:
    print '%s API key seems to be wrong. Please check: %s' % (I('prompt_error'), os.path.split(j)[1])
    return False

  return data