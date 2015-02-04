import json as j

def loadData(file_input):
	data = j.load(open(file_input))[0]
	json = j.dumps(data)
	print len(j.load(open(file_input))[0]["dataset.250"])
	return(json)

payload = loadData("data/data.json")
# print(payload)