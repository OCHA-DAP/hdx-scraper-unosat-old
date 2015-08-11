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


def CreateDatasets(dataset_dict, hdx_site, apikey, verbose=True, update_all_datasets=False):
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

    if check["success"] is True and check['result']['state'] != "deleted":

      #
      # Only update datasets if
      # required. Otherwise skip.
      #
      if update_all_datasets is True:
        print "%s Dataset exists. Updating. %s" % (I('prompt_warn'), dataset["name"])
        r = requests.post(package_update_url, data=json.dumps(dataset), headers=headers, auth=('dataproject', 'humdata'))

      else:
        i += 1
        if verbose:
          print "%s Dataset exists. Skipping %s" % (I('prompt_warn'), dataset["name"])
        continue


    #
    # If package doesn't exist,
    # create it.
    #
    else:
      r = requests.post(package_create_url, data=json.dumps(dataset), headers=headers, auth=('dataproject', 'humdata'))


      if r.status_code != 200:
        if verbose:
          print "%s failed to create %s" % (I('prompt_error'), dataset["name"])

      else:
        if verbose:
          print "%s created successfully %s" % (I('prompt_success'), dataset["name"])

      i += 1

  if verbose is False:
    pbar.finish()

  print "--------------------------------------------------"
  return True



def CreateResources(resource_dict, hdx_site, apikey, verbose=True, update_all_datasets=False):
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
  package_show_url = hdx_site + '/api/action/package_show?id='
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


    #
    # Check if the resource has
    # null resources.
    #
    if resource["format"] is None:
      if verbose:
        print "%s skipping %s" % (I('prompt_warn'), resource["name"])
      continue

    #
    # Create all resources if
    # it is required.
    #
    if update_all_datasets:
      r = requests.post(resource_create_url, data=json.dumps(resource), headers=headers, auth=('dataproject', 'humdata'))
      i += 1

    #
    # Otherwise, check if resource exists.
    #
    else:

      #
      # Fetching the resource list
      # and making an array of its names.
      #
      req = requests.get(package_show_url + resource["package_id"], headers=headers, auth=('dataproject', 'humdata'))
      existing_resources = req.json()
      names_array = []

      if req.status_code != 200:
        continue

      for existing_resource in existing_resources['result']['resources']:
        names_array.append(existing_resource.get('name'))

      #
      # Comparing existing resources
      # with to-be-created ones.
      # If it exists, continue.
      #
      if resource['name'] in names_array:
        i += 1
        if verbose:
          print "%s Resource exists. Skipping %s" % (I('prompt_warn'), resource["name"])
        continue

      else:
        i += 1
        if verbose:
          print "%s Creating resource %s" % (I('prompt_bullet').decode('utf-8'), resource["name"])
        r = requests.post(resource_create_url, data=json.dumps(resource), headers=headers, auth=('dataproject', 'humdata'))


    #
    # Printing status.
    #
    if r.status_code != 200:
      if verbose:
        print "%s failed to create %s" % (I('prompt_error'), resource["name"])

    else:
      if verbose:
        print "%s created successfully %s" % (I('prompt_success'), resource["name"])



  if verbose is False:
    pbar.finish()

  print "--------------------------------------------------"
  return True



def CreateGalleryItems(gallery_dict, hdx_site, apikey, verbose=True, update_all_datasets=False):
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


  for item in gallery_dict:

    if verbose is False:
      pbar.update(i)

    dataset = requests.get(package_show_url + item["dataset_id"], headers=headers, auth=('dataproject', 'humdata')).json()
    if dataset["success"] is True:
      old_related = requests.get(related_list_url + item["dataset_id"], headers=headers, auth=('dataproject', 'humdata')).json()

      #
      # Checking if there are more than 1 gallery items.
      # This is a prevention in order to avoid deleting
      # unwanted items.
      #
      if len(old_related["result"]) > 1:
        print "%s Dataset %s has more than one gallery item. Please check manually." % (I('prompt_bullet').decode('utf-8'), item["dataset_id"])
        continue


      def _delete_old(old_array):
        #
        # Deleting old gallery items.
        #
        for result in old_array["result"]:
          u = { 'id': result["id"] }
          requests.post(related_delete_url, data=json.dumps(u), headers=headers, auth=('dataproject', 'humdata'))
          if verbose:
            print "%s Existing gallery item. Deleting. %s" % (I('prompt_warn'), result["id"])

      #
      # If update all datasets,
      # create a gallery item.
      # If not, check if it exists.
      #
      if update_all_datasets:
        i += 1
        _delete_old(old_related)
        r = requests.post(related_create_url, data=json.dumps(item), headers=headers, auth=('dataproject', 'humdata'))

      else:

        #
        # Checking if gallery item
        # already exists. If it doesn't
        # create it.
        #
        related_array = []
        for result in old_related["result"]:
          related_array.append(result.get('url'))

        if item['url'] in related_array:
          i += 1
          if verbose:
            print "%s Gallery item exists. Skipping. %s" % (I('prompt_warn'), item["url"])
          continue

        else:
          i += 1
          _delete_old(old_related)
          r = requests.post(related_create_url, data=json.dumps(item), headers=headers, auth=('dataproject', 'humdata'))
          print "%s Creating gallery item. %s" % (I('prompt_bullet').decode('utf-8'), item["url"])


      if r.status_code != 200:
        if verbose:
          print "%s failed to create %s" % (I('prompt_error'), item["url"])

      else:
        if verbose:
          print "%s created successully %s" % (I('prompt_success'), item["url"])


  if verbose is False:
    pbar.finish()

  print "--------------------------------------------------"
  return True
