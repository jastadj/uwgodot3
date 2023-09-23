extends Node

var uw1_data = {"path":"./uw_data", "loaded":false, "palettes":{}, "images":{}}
var cur_data = uw1_data

func load_uw1_resources(callable:Callable):
	
	var manifest_loader = load("res://resource_loaders/manifest.gd").new()
	var uw1_path = uw1_data["path"]
	var manifest_file = "res://system/manifests/uw1_manifest.csv"
	
	manifest_loader.connect("loading", callable)
	
	# UW Data Path
	var data_path = str(uw1_path + "/UWDATA/")
	
	print("Loading UW1 resources...")
	cur_data = uw1_data
	
	# Load files from manifest
	manifest_loader.load_manifest_file(cur_data, manifest_file, data_path)
		
	return true
