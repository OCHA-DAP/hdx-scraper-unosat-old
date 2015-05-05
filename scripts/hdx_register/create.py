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


def CreateResources(resource_dict, hdx_site, apikey, verbose=True):
  '''Create datasets based on dictionaries.'''
  
  if verbose:
    print "--------------------------------------------------"
    print "//////////////////////////////////////////////////"
    print "--------------------------------------------------"
    print "///////////// CREATING RESOURCES /////////////////"
    print "--------------------------------------------------"
    print "//////////////////////////////////////////////////"
    print "--------------------------------------------------"

  # Checking for input.
  if (resource_dict is None):
    print "No data provided. Provide a JSON package."
    print "--------------------------------------------------"
    return

  # Base config.
  resource_create_url = hdx_site + 'api/action/resource_create'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }


  #
  # Progress bar.
  #
  i = 0
  widgets = [I('prompt_bullet'), ' Creating resources:', pb.Percentage(), ' ', pb.Bar('-'), ' ', pb.ETA(), ' ']

  if verbose is False:
    pbar = pb.ProgressBar(widgets=widgets, maxval=len(resource_dict)).start()


  for resource in resource_dict:
    if verbose is False: 
        pbar.update(i)

    if resource["format"] is None:
      print "%s skipping %s" % (I('prompt_warn'), resource["name"])
      continue

    # Adding resources.
    r = requests.post(resource_create_url, data=json.dumps(resource), headers=headers, auth=('dataproject', 'humdata'))

    if verbose is True:
      print "Status code: ", r.status_code

    if r.status_code != 200:
      if verbose:
        print "%s failed to create %s" % (I('prompt_error'), resource["name"])

    else:
      if verbose:
        print "%s created successfully %s" % (I('prompt_success'), resource["name"])

    i += 1

  pbar.finish()
  print "--------------------------------------------------"
  return True


def CreateGalleryItems(gallery_dict, hdx_site, apikey, verbose=True):
  '''Create datasets based on dictionaries.'''
  
  if verbose:
    print "--------------------------------------------------"
    print "//////////////////////////////////////////////////"
    print "--------------------------------------------------"
    print "//////////// CREATING GALLERY ITEMS //////////////"
    print "--------------------------------------------------"
    print "//////////////////////////////////////////////////"
    print "--------------------------------------------------"

  # Checking for input.
  if (gallery_dict is None):
    print "No data provided. Provide a JSON package."
    print "--------------------------------------------------"
    return

  # Base config.
  package_show_url = hdx_site + '/api/action/package_show?id='
  related_list_url = hdx_site + '/api/action/related_list?id='
  related_delete_url = hdx_site + '/api/action/related_delete?id='
  related_create_url = hdx_site + '/api/action/related_create'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }


  #
  # Progress bar.
  #
  i = 0
  widgets = [I('prompt_bullet'), ' Creating gallery items:', pb.Percentage(), ' ', pb.Bar('-'), ' ', pb.ETA(), ' ']

  if verbose is False:
    pbar = pb.ProgressBar(widgets=widgets, maxval=len(gallery_dict)).start()

  #
  # Iterating over every dataset.
  #
  for item in gallery_dict:

    if verbose is False: 
        pbar.update(i)

    dataset = requests.get(package_show_url + item["dataset_id"], headers=headers, auth=('dataproject', 'humdata')).json()
    if dataset["success"] is True:
        old_related = requests.get(related_list_url + item["dataset_id"], headers=headers, auth=('dataproject', 'humdata')).json()

        # Checking if there are more than 1 gallery items.
        # This is a prevention in order to avoid deleting
        # unwanted items.
        if len(old_related["result"]) > 1:
            print "Dataset %s has more than one gallery item. Please check manually." % (item["dataset_id"])
            break  # or continue?

        # Deleting old gallery items.
        for result in old_related["result"]:
            u = { 'id': result["id"] }
            re = requests.post(related_delete_url, data=json.dumps(u), headers=headers, auth=('dataproject', 'humdata'))

            print "%s deleted %s" % (I('prompt_warn'), result["id"])

        # Adding gallery items.
        r = requests.post(related_create_url, data=json.dumps(item), headers=headers, auth=('dataproject', 'humdata'))

        if verbose is True:
            print "Status code: ", r.status_code
            print r.json()

        if r.status_code != 200:
          if verbose:
            print "%s failed to create %s" % (I('prompt_error'), item["url"])

        else:
          if verbose:
            print "%s created successully %s" % (I('prompt_success'), item["url"])

        i += 1

  pbar.finish()
  print "--------------------------------------------------"
  return True


def CreateDatasets(dataset_dict, hdx_site, apikey, verbose=True):
  '''Create datasets based on dictionaries.'''

  if verbose:
    print "--------------------------------------------------"
    print "//////////////////////////////////////////////////"
    print "--------------------------------------------------"
    print "////////////// CREATING DATASETS /////////////////"
    print "--------------------------------------------------"
    print "//////////////////////////////////////////////////"
    print "--------------------------------------------------"

  # Checking for input.
  if (dataset_dict is None):
    print "No data provided. Provide a JSON package."
    print "--------------------------------------------------"
    return

  # Base config.
  package_show_url = hdx_site + '/api/action/package_show?id='
  package_create_url = hdx_site + '/api/action/package_create'
  package_update_url = hdx_site + '/api/action/package_update'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }
  

  #
  # Progress bar.
  #
  i = 0
  widgets = [I('prompt_bullet'), ' Creating datasets:', pb.Percentage(), ' ', pb.Bar('-'), ' ', pb.ETA(), ' ']

  if verbose is False:
    pbar = pb.ProgressBar(widgets=widgets, maxval=len(dataset_dict)).start()

  #
  # Iterating over every dataset.
  #
  for dataset in dataset_dict:
    if verbose is False: 
      pbar.update(i)

    check = requests.get(package_show_url + dataset["name"], headers=headers, auth=('dataproject', 'humdata')).json()

    if check["success"] is True:
      print "%s updating %s" % (I('prompt_warn'), dataset["name"])

      # Action
      r = requests.post(package_update_url, data=json.dumps(dataset), headers=headers, auth=('dataproject', 'humdata'))

    else:
      r = requests.post(package_create_url, data=json.dumps(dataset), headers=headers, auth=('dataproject', 'humdata'))
    # r.raise_for_status()

    if verbose is True:
      print "Status code: ", r.status_code
      # print r.json()

    if r.status_code != 200:
      if verbose:
        print "%s failed to create %s" % (I('prompt_error'), dataset["name"])

    else:
      if verbose:
        print "%s created successfully %s" % (I('prompt_success'), dataset["name"])

    i += 1
  
  pbar.finish()
  print "--------------------------------------------------"
  return True
