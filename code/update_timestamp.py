  # Base config.
  base_url = 'https://test-data.hdx.rwlabs.org/api/action/package_create'
  headers = { 'X-CKAN-API-Key': apikey, 'content-type': 'application/json' }

  # Use the json module to dump the dictionary to a string for posting.
#   for i in range(0,len(dataset_dict)):

  # url = "https://test-data.hdx.rwlabs.org/api/action/package_show?id=141121-sierra-leone-health-facilities"
  # update_url = "https://test-data.hdx.rwlabs.org/api/action/package_update"
  # r = requests.post(url, headers=headers, auth=('dataproject', 'humdata'))
  # r.raise_for_status()
  # payload = r.json()["result"]
  # payload["dataset_date"] = "01/02/2015"
  # print "Got data."
  # r = requests.post(update_url, json=payload, headers=headers, auth=('dataproject', 'humdata'))
  # r.raise_for_status()
  # print r.status_code
