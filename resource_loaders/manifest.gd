extends Node

enum RESOURCE_TYPES{PALETTE, AUX_PALETTE, TEXTURE, GRAPHIC, BITMAP}

signal loading(loadstring, cur, total)

func load_manifest_file(uw_data:Dictionary, manifest_filename:String, data_path_str:String):
		
	var MANIFEST_HEADER = PackedStringArray(["Filename","Type","Base","Name", "Palette"])
	var manifest_entries = []
	var line_counter = 0
	var data_path = DirAccess.open(data_path_str)
	var data_path_files = null
	var palettes = null
	
	print(uw_data)
	
	# Check that the data_path directory exists.
	if(!data_path):
		printerr("Error loading manifest file, unable to find data directory:", data_path_str)
		return false
	
	# Get files in data directory.
	data_path_files = data_path.get_files()
	
	# Resource Loaders
	var palette_loader = load( "res://resource_loaders/palettes.gd")
	var graphics_loader = load("res://resource_loaders/graphics.gd")
	
	# Is uw_data a Dictionary?
	if!(uw_data is Dictionary):
		printerr("Error reading manifest file, argument is not a valid dictionary!")
	
	# Open manifest file.
	var tfile = FileAccess.open(manifest_filename, FileAccess.READ)
	if(tfile == null):
		printerr("Error opening manifest file:" + manifest_filename)
		tfile.close()
		return false
	
	# Read in manifest header
	var header = tfile.get_csv_line()
	if(header != MANIFEST_HEADER):
		printerr("Error reading manifest file, unexpected header.")
		tfile.close()
		return false
	
	line_counter = 1
	
	# Read in each manifest entry and load the resource.
	while !tfile.eof_reached():
		var manifest_entry = tfile.get_csv_line()
		
		# Ignore empty lines (generally at the EOF)
		if(manifest_entry.size() == 0 or manifest_entry.size() == 1):
			continue
		
		# Does this entry not match the same element count as the header?
		if(manifest_entry.size() != MANIFEST_HEADER.size()):
			printerr("Manifest entry on line ", line_counter," does not match header width.")
			tfile.close()
			return false
		
		manifest_entries.append(manifest_entry)
	
	for entryi in range(0,manifest_entries.size()):
		var entry = manifest_entries[entryi]
		var filename = entry[0]
		var filepath
		var type = entry[1].to_upper()
		var base = entry[2]
		var keyname = entry[3]
		var palette = entry[4]
		
		emit_signal("loading", [filename,entryi, manifest_entries.size()])
		
		if (palettes != null):
			if (palette == ""): palette = 0
			else: palette = palette.to_int()
		
		# Does file exist?
		if(!data_path_files.has(filename)):
			printerr("Error loading manifest, unable to find file on line ",line_counter,":", filename)
			tfile.close()
			return false
			
		filepath = data_path_str + "/" + filename
		
		# Does type exists?
		if(!RESOURCE_TYPES.has(type)):
			printerr("Error loading manifest, resource type ",type," unknown.")
			tfile.close()
			return false
		
		# If Base Key does not exist, create it.
		if(!uw_data.has(base)): uw_data[base] = {}
		
		# If Name Key does not exist, create it.
		if(!uw_data[base].has(keyname)): uw_data[base][keyname] = []
		
		
		
		# Load the resource type.
		var result
		match(RESOURCE_TYPES.get(type)):
			RESOURCE_TYPES.PALETTE:
				result = palette_loader.load_palette_file(filepath)
			RESOURCE_TYPES.AUX_PALETTE:
				result = palette_loader.load_aux_palette_file(filepath)
			RESOURCE_TYPES.TEXTURE:
				if(palettes == null):
					printerr("Error loading texture file, no available palettes.")
					return false
				result = graphics_loader.load_image_file(filepath, palettes["main"][palette])
			RESOURCE_TYPES.GRAPHIC:
				if(palettes == null):
					printerr("Error loading graphics file, no available palettes.")
					return false
				result = graphics_loader.load_image_file(filepath, palettes["main"][palette])
			RESOURCE_TYPES.BITMAP:
				if(palettes == null):
					printerr("Error loading bitmap file, no available palettes.")
					return false
				result = graphics_loader.load_bitmap_file(filepath, palettes["main"][palette])
			_:
				printerr("Error loading manifest, unhandled resource type ", type)
				tfile.close()
				return false
		
		if (result is bool):
			printerr("Error loading resource type ", type, " from file ", filepath)
			tfile.close()
			return false
		
		print("Loaded ", result.size(), " entries of ", type," to [",base,"][", keyname,"]")
		
		# Add resource to data.
		for element in result:
			uw_data[base][keyname].append(element)
		
		if(palettes == null):
			if(uw_data.has("palettes")): palettes = uw_data["palettes"]
		
		line_counter += 1
	
	tfile.close()
	return true
