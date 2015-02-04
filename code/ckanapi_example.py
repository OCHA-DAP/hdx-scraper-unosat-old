import ckanapi

###################
## Configuration ##
###################
apikey = 'XXX'

def createDatasets():
	hdx = ckanapi.RemoteCKAN('https://data.hdx.rwlabs.org',
	    apikey=apikey,
	    user_agent='ckanapiexample/1.0')
	try:
	    pkg = hdx.action.package_create(
	    	name='testing_creation_via_api_once_more',
	    	title='(TEST) Package Creation via API',
	    	notes='testing',
	    	owner_org='hdx',
	    	package_creator='luiscape',
	    	dataset_source='test',
	    	private=True
	    	)
	except ckanapi.NotAuthorized:
	    print 'No API key provided. Please provide an API key.'
	except ckanapi.ValidationError:
		print 'Some fields are missing.'
