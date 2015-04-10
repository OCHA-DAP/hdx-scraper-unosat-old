# Script to extract features from GeoJSON files
# making the resulting files a collection of features
# without the proper GeoJSON "wrapper".

## TODO:
# - Create function to delete all datasets from UNOSAT.

import sys
import yajl as json
import requests
from termcolor import colored as color

###################
## Configuration ##
###################
apikey = 'a6863277-f35e-4f50-af85-78a2d9ebcdd3'  # consider adding key via cli
datasets_path = 'data/datasets.json'
resources_path = 'data/resources.json'
gallery_path = 'data/gallery.json'
verbose = False
delete_resources = True  # This will delete all datasets before adding.
delete_datasets = True  # This will delete ALL dataset from the org.

# Loading data from a local resource.
def loadData(p, verbose=verbose):
    if verbose is True:
        print "--------------------------------------------------"
        print "Loading JSON data from %s." % p

    try:
        data = json.load(open(p))

        if verbose is True:
            print "Data loaded successully. %s entities in dataset:" % (len(data[0]))

        return(data[0])

    except Exception as e:
        print "Could not load %s file." % (p)
        return(None)

    if verbose is True:
        print "--------------------------------------------------"


####################
###### Logic #######
####################

# Function to delete all datasets owned by an organization.
def deleteAllDatasetsFromOrg(organization, apikey):

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
    return

  # Base config.
  organization_show_url = 'https://test-data.hdx.rwlabs.org/api/action/organization_show?id='
  package_delete_url = 'https://test-data.hdx.rwlabs.org/api/action/package_delete'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }

  # Fetching dataset information.
  dataset_dict = requests.get(organization_show_url + organization, headers=headers, auth=('dataproject', 'humdata')).json()

  if dataset_dict["success"] is True:
    for dataset in dataset_dict["result"]["packages"]:
      # Deleting previous datasets to make sure
      # we have a hyper-clean run.
      # Action
      u = { 'id': dataset["id"] }
      r = requests.post(package_delete_url, data=json.dumps(u), headers=headers, auth=('dataproject', 'humdata'))

      if r.status_code != 200:
        message = color("FAIL", "red", attrs=['bold'])
        print "%s : %s" % (dataset["name"], message)

      else:
        message = color("SUCCESS", "green", attrs=['bold'])
        print "%s : %s" % (dataset["name"], message)

  else:
    print "There was an error getting the dataset list."
    print "--------------------------------------------------"
    return



# Function to create datasets based on dictionaries.
def createDatasets(dataset_dict, apikey, verbose=verbose):

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
  package_show_url = 'https://test-data.hdx.rwlabs.org/api/action/package_show?id='
  package_create_url = 'https://test-data.hdx.rwlabs.org/api/action/package_create'
  package_update_url = 'https://test-data.hdx.rwlabs.org/api/action/package_update'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }

  for dataset in dataset_dict:
      check = requests.get(package_show_url + dataset["name"], headers=headers, auth=('dataproject', 'humdata')).json()
      if check["success"] is True:
        # Message
        message = color("UPDATING", "yellow", attrs=['bold'])
        print "%s : %s" % (dataset["name"], message)

        # Action
        r = requests.post(package_update_url, data=json.dumps(dataset), headers=headers, auth=('dataproject', 'humdata'))

      else:
        r = requests.post(package_create_url, data=json.dumps(dataset), headers=headers, auth=('dataproject', 'humdata'))
      # r.raise_for_status()

      if verbose is True:
        print "Status code: ", r.status_code
        # print r.json()

      if r.status_code != 200:
        message = color("FAIL", "red", attrs=['bold'])
        print "%s : %s" % (dataset["name"], message)

      else:
        message = color("SUCCESS", "green", attrs=['bold'])
        print "%s : %s" % (dataset["name"], message)


  print "--------------------------------------------------"


# Function to delete resources. It helps "clean-up"
# datasets before adding resources to them.
def deleteResources(dataset_dict, apikey, verbose=verbose):

  print "--------------------------------------------------"
  print "//////////////////////////////////////////////////"
  print "--------------------------------------------------"
  print "///////////// DELETING RESOURCES /////////////////"
  print "--------------------------------------------------"
  print "//////////////////////////////////////////////////"
  print "--------------------------------------------------"

  # Checking for input.
  if (dataset_dict is None):
    print "No data provided. Provide a JSON package."
    print "--------------------------------------------------"
    return

  # Base config.
  package_show_url = 'https://test-data.hdx.rwlabs.org/api/action/package_show?id='
  resource_delete_url = 'https://test-data.hdx.rwlabs.org/api/action/resource_delete'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }

  for dataset in dataset_dict:
      # Fetching dataset information.
      d = requests.get(package_show_url + dataset["name"], headers=headers, auth=('dataproject', 'humdata')).json()

      if d["success"] is True:
          # Deleting previous resources to make sure
          # the new batch is the most up-to-date.
          for resource in d["result"]["resources"]:
            # Message
            message = color("RESOURCE DELETED", "green", attrs=['bold'])
            print "%s : %s" % (resource["id"], message)

            # Action
            u = { 'id': resource["id"] }
            requests.post(resource_delete_url, data=json.dumps(u), headers=headers, auth=('dataproject', 'humdata'))


# Function to create datasets based on dictionaries.
def createResources(resource_dict, apikey, verbose=verbose):

  print "--------------------------------------------------"
  print "//////////////////////////////////////////////////"
  print "--------------------------------------------------"
  print "///////////// CREATING RESOURCES /////////////////"
  print "--------------------------------------------------"
  print "//////////////////////////////////////////////////"
  print "--------------------------------------------------"

  # Checking for input.
  if (dataset_dict is None):
    print "No data provided. Provide a JSON package."
    print "--------------------------------------------------"
    return

  # Base config.
  resource_create_url = 'https://test-data.hdx.rwlabs.org/api/action/resource_create'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }

  for resource in resource_dict:
      if resource["format"] is None:
        message = color("SKIPPING", "yellow", attrs=['bold'])
        print "%s : %s" % (resource["name"], message)
        continue

      # Adding resources.
      r = requests.post(resource_create_url, data=json.dumps(resource), headers=headers, auth=('dataproject', 'humdata'))

      if verbose is True:
        print "Status code: ", r.status_code
        # print r.json()

      if r.status_code != 200:
        message = color("FAIL", "red", attrs=['bold'])
        print "%s : %s" % (resource["name"], message)

      else:
        message = color("SUCCESS", "green", attrs=['bold'])
        print "%s : %s" % (resource["name"], message)


# Function to create datasets based on dictionaries.
def createGalleryItems(gallery_dict, apikey, verbose=verbose):

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
  package_show_url = 'https://test-data.hdx.rwlabs.org/api/action/package_show?id='
  related_list_url = 'https://test-data.hdx.rwlabs.org/api/action/related_list?id='
  related_delete_url = 'https://test-data.hdx.rwlabs.org/api/action/related_delete?id='
  related_create_url = 'https://test-data.hdx.rwlabs.org/api/action/related_create'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }

  for item in gallery_dict:
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

            message = color("DELETED", "yellow", attrs=['bold'])
            print "%s : %s" % (result["id"], message)

        # Adding gallery items.
        r = requests.post(related_create_url, data=json.dumps(item), headers=headers, auth=('dataproject', 'humdata'))

        if verbose is True:
            print "Status code: ", r.status_code
            print r.json()

        if r.status_code != 200:
          message = color("FAIL", "red", attrs=['bold'])
          print "%s : %s" % (item["url"], message)

        else:
          message = color("SUCCESS", "green", attrs=['bold'])
          print "%s : %s" % (item["url"], message)

  print "--------------------------------------------------"



try:
  # Loading dictionaries.
  dataset_dict = loadData(datasets_path)
  resource_dict = loadData(resources_path)
  gallery_dict = loadData(gallery_path)

  # Delete all datasets before running:
  if delete_datasets is True:
    deleteAllDatasetsFromOrg("un-operational-satellite-appplications-programme-unosat", apikey=apikey)

  # Delete resources before running:
  if delete_resources is True:
    deleteResources(dataset_dict=dataset_dict, apikey=apikey)

  # Creating datasets.
  createDatasets(dataset_dict=dataset_dict, apikey=apikey)
  createResources(resource_dict=resource_dict, apikey=apikey)
  createGalleryItems(gallery_dict=gallery_dict, apikey=apikey)

except Exception as e:
  print e