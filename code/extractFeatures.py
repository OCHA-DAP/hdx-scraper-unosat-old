# Script to extract features from GeoJSON files
# making the resulting files a collection of features
# without the proper GeoJSON "wrapper".

import sys
import yajl as json
# from pprint import pprint

# For providing command line arguments.
if __name__ == '__main__':
    if len(sys.argv) <= 1:
        usage = '''python extractFeatures.py {file_path}

        e.g.

        python extractFeatures.py world_boundaries_adm0.geojson
        '''
        print(usage)
        sys.exit(1)

# Collecting system parameters.
file_input = sys.argv[1]

# Defining the main function.
def extractFeatures(file_input):
    data = json.load(open(file_input))
    # with open(file_output, "w") as file_output:
        # json.dump(data, file_output)

    print "Entities in dataset:", len(data)

# Running.
extractFeatures(file_input=file_input)