extends Node

var uw1_data = {"path":"./uw_data", "loaded":false, "palettes":{}, "images":{}}
var cur_data = uw1_data

func _ready():
	
	uw1_data["loaded"] = load_uw1_resources()

func load_uw1_resources():
	
	var manifest_loader = load("res://resource_loaders/manifest.gd")
	var uw1_path = uw1_data["path"]
	var manifest_file = "res://system/manifests/uw1_manifest.csv"
	
	# UW Data Path
	var data_path = str(uw1_path + "/UWDATA/")
	
	print("Loading UW1 resources...")
	cur_data = uw1_data
	
	# Load files from manifest
	manifest_loader.load_manifest_file(cur_data, manifest_file, data_path)
	
#	# Load Palettes
#	cur_file = "PALS.DAT"
#	if(!file_exists_in(cur_file, uw1_files)):return false
#	uw1_data["palettes"]["main"] = palette_loader.load_palette_file(data_path + cur_file)
#	print("Loaded ", uw1_data["palettes"]["main"].size(), " palettes.")
#
#	# Load Aux Palettes
#	cur_file = "ALLPALS.DAT"
#	if(!file_exists_in(cur_file, uw1_files)):return false
#	uw1_data["palettes"]["aux"] = palette_loader.load_aux_palette_file(data_path + cur_file)
#	print("Loaded ", uw1_data["palettes"]["aux"].size(), " aux palettes.")
#
#	# Load Walls 16
#	cur_file = "W16.TR"
#	if(!file_exists_in(cur_file, uw1_files)):return false
#	uw1_data["images"]["walls_16"] = graphics_loader.load_texture_file(data_path + cur_file)
#	print("Loaded ", uw1_data["images"]["walls_16"].size(), " wall 16 textures.")
#
#	# Load Walls 64
#	cur_file = "W64.TR"
#	if(!file_exists_in(cur_file, uw1_files)):return false
#	uw1_data["images"]["walls_64"] = graphics_loader.load_texture_file(data_path + cur_file)
#	print("Loaded ", uw1_data["images"]["walls_64"].size(), " wall 64 textures.")
	
	return true
