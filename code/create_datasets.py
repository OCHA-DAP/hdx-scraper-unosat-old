#!/usr/bin/env python

import json
import requests

###################
## Configuration ##
###################
apikey = '4a4ed4e3-571b-4b99-9bc1-ae1df26b77a8'

####################
## Data Dictionay ##
####################
dataset_dict = [
		{
		    'name': 'testing_creation_via_api_ketng_34',
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
		    # 'resources': [{
					 #    	'package_id' : 'shapefile_of_x.shp',
					 #    	'url':'http://example.com',
					 #    	'name': 'shapefile_of_x.shp'
					 #     }]
		    'tags': [{'name':'test' }],
		    'groups': [{ 'title': "Guinea", 'id': "gin", 'name': "gin" }],
		    'owner_org': 'un-operational-satellite-appplications-programme-unosat'
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
