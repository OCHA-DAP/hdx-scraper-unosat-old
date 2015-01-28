#!/usr/bin/env python
import json
import pprint
import requests
import urllib2
import urllib

###################
## Configuration ##
###################
apikey = 'XXX'


####################
## Data Dictionay ##
####################
# Put the details of the dataset we're going to create into a dict.

dataset_dict = [
		{
		    'name': 'testing_creation_via_api',
		    'title': '(TEST) Dataset Created via the API',
		    'author': 'luiscape',
		    'author_email': 'capelo@un.org',
		    'maintainer':'luiscape',
		    'maintainer_email':'capelo@un.org',
		    'license_id': 'hdx-other',
		    'license_other': "foo bar",
		    'notes': 'A longer description of this test',
		    'private': True,
		    'url': None,
		    'state': 'active',
		    # 'resources': []
		    'tags': 'test',
		    'groups': [{ 'title': "Guinea", 'id': "gin", 'name': "gin" }],
		    'owner_org': 'hdx'
		}
	]

def createDataset(dataset_dict,apikey):
	# Use the json module to dump the dictionary to a string for posting.
	payload = json.dumps(dataset_dict[0])
	base_url = 'https://data.hdx.rwlabs.org/api/action/package_create'
	headers = { 'Authorization': apikey }

	# Making request
	r = requests.get(base_url, params=payload, headers=headers)

	# Raise if there are errors
	r.raise_for_status()

createDataset(dataset_dict=dataset_dict, apikey=apikey)