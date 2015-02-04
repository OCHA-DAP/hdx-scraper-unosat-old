#!/usr/bin/env python

######################
#### Dependencies ####
######################
import json
import requests

###################
## Configuration ##
###################
apikey = 'XXX'

####################
## Data Dictionay ##
####################
# Loading data from a local JSON file.
def loadData():
	# 

dataset_dict = [
		{
		    'name': 'testing_creation_via_apis_2',
		    'title': '(TEST) Dataset Created via the API',
		    'author': 'luiscape',
		    'author_email': 'capelo@un.org',
		    'maintainer':'luiscape',
		    'maintainer_email':'capelo@un.org',
		    'license_id': 'hdx-other',
		    'license_other': "foo bar",
		    'notes': 'A longer description of this test',
		    'dataset_source':'UNOSAT',
		    'package_creator':'hdx',
		    'private': True,
		    'url': None,
		    'state': 'active',
		    'resources': [{
					    	'package_id' : 'shapefile_of_x.shp',
					    	'url':'http://example.com',
					    	'name': 'shapefile_of_x.shp'
					     }],
		    'tags': [{'name':'test' }],
		    'groups': [{ 'title': "Guinea", 'id': "gin", 'name': "gin" }, { 'title': "Guinea", 'id': "gin", 'name': "gin" }],
		    'owner_org': 'hdx'
		    # 'owner_org': 'un-operational-satellite-appplications-programme-unosat'
		}
	]

# Related items have to be created separatelly, using the related_create API.
related_dict = [
	{
		'title': 'XXX',
		'type': 'paper',
		'description': 'XXX',
		'url': 'XXX',
		'image_url':'XXX',
		'dataset_id':'XXX'
	}
]

####################
###### Logic #######
####################
# Function to create datasets based on dictionaries.
def createDataset(dataset_dict,apikey):
	# Use the json module to dump the dictionary to a string for posting.
	for i in range(0,len(dataset_dict)):
		payload = json.dumps(dataset_dict[i])
		base_url = 'http://data.hdx.rwlabs.org/api/action/package_create'
		headers = { 'Authorization': apikey, 'content-type': 'application/json' }

		# Making request
		r = requests.post(base_url, data=payload, headers=headers)

		# Raise if there are errors
		r.raise_for_status()

try:
	createDataset(dataset_dict=dataset_dict, apikey=apikey)
	print("You've created the %s dataset.", dataset_dict[0]["name"])
except Exception as e:
	print e
