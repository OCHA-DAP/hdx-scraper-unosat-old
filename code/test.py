import json

def loadData(file_input):
	data = json.load(open(file_input))[0]
	print(json.dumps(data))
	print(len(data))

loadData("data/data.json")