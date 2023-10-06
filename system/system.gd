extends Node

const raws_file = "raws.json"
enum IMAGE_FORMAT{FMT_8BIT = 0x04, FMT_4BIT = 0x0a, FMT_4BIT_RLE = 0x08, FMT_5BIT_RLE = 0x06}
enum TILE_TYPES{SOLID, OPEN, DIAG_OPEN_SE, DIAG_OPEN_SW, DIAG_OPEN_NE, DIAG_OPEN_NW, SLOPE_UP_N, SLOPE_UP_S, SLOPE_UP_E, SLOPE_UP_W}

# data types
var image_type = load("res://system/data_types/image.gd").new()
var font_type = load("res://system/data_types/font.gd").new()

var uw1_data = {"name":"uw1","path":"./uw_data", "loaded":false, "raws":{} ,"palettes":{}, "images":{}, "fonts":{}}
var cur_data = uw1_data

signal loading_status

func _ready():
	pass

func import_uw1_resources(callable:Callable):
	
	var manifest_loader = load("res://resource_loaders/manifest.gd").new()
	var uw1_path = uw1_data["path"]
	var manifest_file = "res://system/manifests/uw1_manifest.csv"
	
	manifest_loader.connect("importing", callable)
	
	print("Importing UW1 resources...")
	cur_data = uw1_data
	
	# Load files from manifest
	return manifest_loader.load_manifest_file(uw1_data, manifest_file)

func save_raws(data:Dictionary):
	var targetpath = str("user://data/",data["name"])
	
	if(!DirAccess.dir_exists_absolute(targetpath)):
		var exportdir = DirAccess.open("user://")
		exportdir.make_dir_recursive(targetpath)
	
	var file = FileAccess.open(str(targetpath,"/",raws_file), FileAccess.WRITE)
	file.store_string(JSON.stringify(data["raws"]))
	print("Saved raw data to ", targetpath, "/", raws_file)
	return true

func load_raws(data_name:String):
	var targetpath = str("user://data/",data_name)
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

func generate_resources_from_raws(data:Dictionary):
	
	var raws = data["raws"]
	
	# generate the main palettes
	data["palettes"] = {}
	data["palettes"]["main"] = []
	for rawpalette in data["raws"]["palettes"]["main"]:
		data["palettes"]["main"].push_back(generate_palette(rawpalette))
		
	# generate aux palettes
	data["palettes"]["aux"] = []
	for rawauxpalette in data["raws"]["palettes"]["aux"]:
		data["palettes"]["aux"].push_back(generate_aux_palette(rawauxpalette, data["palettes"]["main"][0]))
	
	# generate images
	for imagekey in data["raws"]["images"].keys():
		data["images"][imagekey] = []
		for entry in data["raws"]["images"][imagekey]:
			var pal = data["palettes"]["main"][entry["palette"]]
			var auxpal = data["palettes"]["aux"][entry["aux_palette"]]
			data["images"][imagekey].push_back(generate_image_from_image_entry(entry, pal, auxpal))
	
	# done
	return true
	
func export_resources(data:Dictionary):
	var targetpath = str("user://data/",data["name"])
	var imagespath = str(targetpath,"/images")	
	
	if(!DirAccess.dir_exists_absolute(targetpath)):
		var exportdir = DirAccess.open("user://")
		exportdir.make_dir_recursive(targetpath)
	
	# save images
	if(!DirAccess.dir_exists_absolute(imagespath)):
		var newdir = DirAccess.open("user://")
		newdir.make_dir_recursive(imagespath)
	for imagekey in data["images"].keys():
		var imagepath = str(imagespath,"/",imagekey)
		if(!DirAccess.dir_exists_absolute(imagepath)):
			var newdir = DirAccess.open("user://")
			newdir.make_dir_recursive(imagepath)
		var imagedir = DirAccess.open(imagepath)
		# save each image
		for imageindex in range(0, data["images"][imagekey].size()):
			var imagefilename = str(imagepath, "/",imageindex,".png")
			data["images"][imagekey][imageindex].save_png(imagefilename)
			
	return true

func delete_imported_data():
	OS.move_to_trash(ProjectSettings.globalize_path("user://data"))

func new_image(type:int, palette_id:int, aux_pal_id:int = -1):
	var entry = image_type.data.duplicate()
	entry["type"] = type
	entry["palette"] = palette_id
	entry["aux_palette"] = aux_pal_id
	return entry

func new_font(space_width:int, height:int, max_width:int):
	var entry = font_type.data.duplicate()
	entry["space_width"] = space_width
	entry["height"] = height
	entry["max_width"] = max_width
	return entry

func generate_image_from_image_entry(image_entry, palette, aux_palette):
	var pixel_data = []
	var alpha_color = palette[0].to_abgr32()
	pixel_data.resize(image_entry["width"]*image_entry["height"]*4)
	if(int(image_entry["type"]) == int(System.IMAGE_FORMAT.FMT_8BIT)):
		for pixeli in range(0, image_entry["data"].size()):
			var color = palette[image_entry["data"][pixeli]].to_abgr32()
			var alpha = 0xff
			if(color == alpha_color): alpha = 0x00
			pixel_data[(pixeli*4)] = color & 0xff
			pixel_data[(pixeli*4)+1] = (color & 0xff00) >> 8
			pixel_data[(pixeli*4)+2] = (color & 0xff0000) >> 16
			pixel_data[(pixeli*4)+3] = alpha
	else:
		for pixeli in range(0, image_entry["data"].size()):
			var color = aux_palette[image_entry["data"][pixeli]].to_abgr32()
			var alpha = 0xff
			if(color == alpha_color): alpha = 0x0
			pixel_data[(pixeli*4)] = color & 0xff
			pixel_data[(pixeli*4)+1] = (color & 0xff00) >> 8
			pixel_data[(pixeli*4)+2] = (color & 0xff0000) >> 16
			pixel_data[(pixeli*4)+3] = alpha
	return Image.create_from_data(image_entry["width"], image_entry["height"],false, Image.FORMAT_RGBA8, pixel_data)

func generate_palette(palette_array:Array):
	var palette = []
	# generate palette
	for color in palette_array:
		palette.append(Color(color[0], color[1], color[2]))
	return palette

func generate_aux_palette(aux_pal_array:Array, reference_palette:Array):
	var aux_palette = []
	# generate palettes
	for index in aux_pal_array:
		aux_palette.append(reference_palette[index])
	return aux_palette

func generate_font_from_font_entry(font_entry):
	var chars = []
	for char in range(0, font_entry["data"].size()):
		var width = int(font_entry["data"][char]["width"])
		var height = int(font_entry["data"][char]["char"].size())
		if ( width == 0): chars.push_back(null)
		else:
			var pixel_data = []
			for bits in font_entry["data"][char]["char"]:
				for n in range(0, width):
					var bit = (int(bits) >> (width-n-1)) & 0x1
					var fillval = 0x00
					if(bit == 0x1):
						fillval = 0xff
					for k in range(0,4): pixel_data.append(fillval)
			chars.push_back(Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, pixel_data))
	return chars

func print_data_keys(data:Dictionary, indent:int = 0):
	var indent_str = String()
	for i in range(0, indent): indent_str += " "
	for key in data.keys():
		print(indent_str, key)
		if(data[key] is Dictionary): print_data_keys(data[key], indent+1)
	

	
