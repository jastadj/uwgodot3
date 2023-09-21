extends Node

enum RESOURCE_TYPES{PALETTE, AUX_PALETTE, TEXTURE}

static func load_manifest_file(uw_data:Dictionary, manifest_filename:String, data_path_str:String):
		
	var MANIFEST_HEADER = PackedStringArray(["Filename","Type","Base","Name"])
	var line_counter = 0
	var data_path = DirAccess.open(data_path_str)
	var data_path_files = null
	var palette0 = null
	
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
		
		var filename = manifest_entry[0]
		var filepath
		var type = manifest_entry[1].to_upper()
		var base = manifest_entry[2]
		var keyname = manifest_entry[3]
		var keydata
		
		# Does file exist?
		if(!data_path_files.has(filename)):
			printerr("Error loading manifest, unable to find file on line ",line_counter,":", filename)
			return false
			
		filepath = data_path_str + "/" + filename
		
		# Does type exists?
		if(!RESOURCE_TYPES.has(type)):
			printerr("Error loading manifest, resource type ",type," unknown.")
			return false
		
		# If Base Key does not exist, create it.
		if(!uw_data.has(base)): uw_data[base] = {}
		
		# If Name Key does not exist, create it.
		if(!uw_data[base].has(keyname)): uw_data[base][keyname] = []
		
		# Load the resource type.
		keydata = uw_data[base][keyname]
		var result
		
		match(RESOURCE_TYPES.get(type)):
			RESOURCE_TYPES.PALETTE:
				result = palette_loader.load_palette_file(filepath)
				if(!palette0): palette0 = result[0]
			RESOURCE_TYPES.AUX_PALETTE:
				result = palette_loader.load_aux_palette_file(filepath)
			RESOURCE_TYPES.TEXTURE:
				if(palette0 == null):
					printerr("Error loading manifest texture file, palette0 undefined.")
					return false
				result = graphics_loader.load_texture_file(filepath, palette0)
			_:
				printerr("Error loading manifest, unhandled resource type ", type)
				return false
		
		if (result is bool):
			printerr("Error loading resource type ", type, " from file ", filepath)
			return false
		
		print("Loaded ", result.size(), " entries of ", type," to [",base,"][", keyname,"]")
		
		# Add resource to data.
		uw_data[base][keyname].append(result)
		
		line_counter += 1
	
	tfile.close()
	return true