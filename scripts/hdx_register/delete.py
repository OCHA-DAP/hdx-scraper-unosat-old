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


def DeleteAllDatasetsFromOrg(organization, hdx_site, apikey, verbose=True):
  '''Delete all datasets owned by an organization.'''

  if verbose:
    print "--------------------------------------------------"
    print "//////////////////////////////////////////////////"
    print "--------------------------------------------------"
    print "////////////// DELETING DATASETS /////////////////"
    print "--------------------------------------------------"
    print "//////////////////////////////////////////////////"
    print "--------------------------------------------------"

  # Checking for input.
  if (organization is None):
    print "No organization id provided. Please provide an organization id."
    print "--------------------------------------------------"
    return False

  # Base config.
  organization_show_url = hdx_site + '/api/action/organization_show?id='
  package_delete_url = hdx_site + '/api/action/package_delete'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }

  # Fetching dataset information.
  dataset_dict = requests.get(organization_show_url + organization, headers=headers, auth=('dataproject', 'humdata')).json()


   
  #
  # Progress bar.
  #
  i = 0
  widgets = [I('prompt_bullet'), ' Deleting resources:', pb.Percentage(), ' ', pb.Bar('-'), ' ', pb.ETA(), ' ']

  if verbose is False:
    pbar = pb.ProgressBar(widgets=widgets, maxval=len(dataset_dict)).start()

  #
  # Iterating over every dataset.
  #
  if dataset_dict["success"] is True:
    
    pbar.update(i)

    for dataset in dataset_dict["result"]["packages"]:
      
      u = { 'id': dataset["id"] }
      r = requests.post(package_delete_url, data=json.dumps(u), headers=headers, auth=('dataproject', 'humdata'))

      if r.status_code != 200:
        print "%s : %s" % (I('prompt_error'), dataset["name"])

      else:
        print "%s : %s" % (I('prompt_success'), dataset["name"])

    i += 1

  else:
    print "%s There was an error getting the dataset list." % I('prompt_error')
    print "--------------------------------------------------"
    return False



def DeleteResources(dataset_dict, hdx_site, apikey, verbose=True):
  '''Delete resources based on a series of dataset ids.'''

  if verbose:
    print "--------------------------------------------------"
    print "//////////////////////////////////////////////////"
    print "--------------------------------------------------"
    print "///////////// DELETING RESOURCES /////////////////"
    print "--------------------------------------------------"
    print "//////////////////////////////////////////////////"
    print "--------------------------------------------------"

  #
  # Checking input.
  #
  if (dataset_dict is None):
    print "%s No data provided. Provide a JSON package." % I('prompt_error')
    print "--------------------------------------------------"
    return

  #
  # URL config.
  #
  package_show_url = hdx_site + '/api/action/package_show?id='
  resource_delete_url = hdx_site + '/api/action/resource_delete'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }
  
  #
  # Progress bar.
  #
  i = 0
  widgets = [I('prompt_bullet'), ' Deleting resources:', pb.Percentage(), ' ', pb.Bar('-'), ' ', pb.ETA(), ' ']

  if verbose is False:
    pbar = pb.ProgressBar(widgets=widgets, maxval=len(dataset_dict)).start()

  #
  # Iterating over every dataset.
  #
  for dataset in dataset_dict:
    if verbose is False: 
      pbar.update(i)

    #
    # Make request to HDX.
    #
    d = requests.get(package_show_url + dataset["name"], headers=headers, auth=('dataproject', 'humdata')).json()

    if d["success"] is False and d['__type'] == 'Not Found Error':
      print '%s There was an error connecting to HDX.' % I('prompt_error')
      if verbose:
       print json.dumps(d['error'])

    
    if d["success"] is True:
      for resource in d["result"]["resources"]:
        if verbose:
          print "%s : resource deleted %s" % (I('prompt_warn'), resource["id"])

        #
        # Delete resource.
        #
        u = { 'id': resource["id"] }
        requests.post(resource_delete_url, data=json.dumps(u), headers=headers, auth=('dataproject', 'humdata'))


    i += 1
  
  if verbose is False:
    pbar.finish()
  return True