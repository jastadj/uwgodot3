extends Node

const raws_file = "raws.json"
enum IMAGE_FORMAT{FMT_8BIT = 0x04, FMT_4BIT = 0x0a, FMT_4BIT_RLE = 0x08, FMT_5BIT_RLE = 0x06}

var uw1_data = {"name":"uw1","path":"./uw_data", "loaded":false, "raws":{} ,"palettes":{}, "images":{}}
var cur_data = uw1_data

func _ready():
	pass

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
	return manifest_loader.load_manifest_file(cur_data["raws"], manifest_file, data_path)

func generate_image_from_image_entry(image_entry, palette, aux_palette):
	var pixel_data = []
	pixel_data.resize(image_entry["width"]*image_entry["height"]*4)
	if(int(image_entry["type"]) == int(System.IMAGE_FORMAT.FMT_8BIT)):
		for pixeli in range(0, image_entry["data"].size()):
			var color = palette[image_entry["data"][pixeli]].to_abgr32()
			pixel_data[(pixeli*4)] = color & 0xff
			pixel_data[(pixeli*4)+1] = (color & 0xff00) >> 8
			pixel_data[(pixeli*4)+2] = (color & 0xff0000) >> 16
			pixel_data[(pixeli*4)+3] = 0xff
	else:
		for pixeli in range(0, image_entry["data"].size()):
			var color = palette[aux_palette[image_entry["data"][pixeli]]].to_abgr32()
			pixel_data[(pixeli*4)] = color & 0xff
			pixel_data[(pixeli*4)+1] = (color & 0xff00) >> 8
			pixel_data[(pixeli*4)+2] = (color & 0xff0000) >> 16
			pixel_data[(pixeli*4)+3] = 0xff
	return Image.create_from_data(image_entry["width"], image_entry["height"],false, Image.FORMAT_RGBA8, pixel_data)

func print_data_keys(data:Dictionary, indent:int = 0):
	var indent_str = String()
	for i in range(0, indent): indent_str += " "
	for key in data.keys():
		print(indent_str, key)
		if(data[key] is Dictionary): print_data_keys(data[key], indent+1)
	
func load_data(data_name:String):
	var targetpath = str("user://export/",data_name)
	if(!DirAccess.dir_exists_absolute(targetpath)): return false
	
	var file = FileAccess.open(str(targetpath,"/",raws_file), FileAccess.READ)
	if(file != null):
		var file_content = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(file_content)
		if(error == OK):
			System.cur_data["raws"] = json.data
			print("Loaded raw data from ", targetpath,"")
			return true
	return false

func save_data(data:Dictionary):
	var targetpath = str("user://export/",data["name"])
	
	if(!DirAccess.dir_exists_absolute(targetpath)):
		var exportdir = DirAccess.open("user://")
		exportdir.make_dir_recursive(targetpath)
	
	var file = FileAccess.open(str(targetpath,"/",raws_file), FileAccess.WRITE)
	file.store_string(JSON.stringify(data["raws"]))
	print("Saved raw data to ", targetpath, "/", raws_file)
	
