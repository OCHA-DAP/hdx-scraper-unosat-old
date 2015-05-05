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

def LoadData(p, verbose=True):
  '''Loading data from a local JSON resource.'''
  
  if verbose:
    print "--------------------------------------------------"
    print "%s Loading JSON data from %s." % (I('prompt_bullet').decode('utf-8'), p)

  try:
      data = json.load(open(p))

      if verbose:
          print "%s Data loaded successully. %s entities in dataset." % (I('prompt_bullet').decode('utf-8'), len(data[0]))
          print "--------------------------------------------------"


  except Exception as e:
      print "%s Could not load %s file." % (I('prompt_error'), p)
      return None


  #
  # Perform basic quality checks.
  #
  return data[0]
