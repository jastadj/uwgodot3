enum RESOURCE_TYPES{PALETTE, AUX_PALETTE, TEXTURE, GRAPHIC, BITMAP, FONT, NPC_ASSOC, NPC_ANIM, LEVELS}

signal importing(loadstring, cur, total)

func load_manifest_file(uw_data:Dictionary, manifest_filename:String):
	
	# manifest data
	var MANIFEST_HEADER = PackedStringArray(["Directory","Filename","Type","Base","Name", "Palette","Anim"])
	var manifest_entries = []
	var line_counter = 0
	
	# Resource Loaders
	var palette_loader = load( "res://resource_loaders/palettes.gd")
	var graphics_loader = load("res://resource_loaders/graphics.gd")
	var font_loader = load("res://resource_loaders/fonts.gd")
	var npc_loader = load("res://resource_loaders/npc.gd")
	var level_loader = load("res://resource_loaders/levels.gd")
	
	# Is uw_data a Dictionary?
	if!(uw_data is Dictionary):
		printerr("Error reading manifest file, argument is not a valid dictionary!")
		return false
	
	# Open manifest file.
	var tfile = FileAccess.open(manifest_filename, FileAccess.READ)
	if(tfile == null):
		printerr("Error opening manifest file:" + manifest_filename)
		return false
	
	# Read in manifest header
	var header = tfile.get_csv_line()
	if(header != MANIFEST_HEADER):
		printerr("Error reading manifest file, unexpected header.")
		return false
	
	line_counter += 1
	
	# Collect manifest entries.
	while !tfile.eof_reached():
		var manifest_entry = tfile.get_csv_line()
			
		# Ignore empty lines (generally at the EOF)
		if(manifest_entry.size() == 0 or manifest_entry.size() == 1):
			continue
		
		# Does this entry not match the same element count as the header?
		if(manifest_entry.size() != MANIFEST_HEADER.size()):
			printerr("Manifest entry on line ", line_counter," does not match header width.")
			return false
		
		manifest_entries.append(manifest_entry)
	
	for entryi in range(0,manifest_entries.size()):
		var entry = manifest_entries[entryi]
		var dir = entry[0]
		var filename = entry[1]
		var filepath = str(uw_data["path"],"/",dir,"/",filename)
		var type = entry[2].to_upper()
		var base = entry[3]
		var keyname = entry[4]
		var palette = entry[5]
		var anim = int(entry[6])
		
		emit_signal("importing", [filepath, entryi, manifest_entries.size()])
		
		# manifest palette entry
		if (palette == ""): palette = 0
		else: palette = palette.to_int()
		
		# Does file exist?
		if(!FileAccess.file_exists(filepath)):
			printerr("Error loading manifest, unable to find file on line ",line_counter,":", filepath)
			return false
		
		# Does type exists?
		if(!RESOURCE_TYPES.has(type)):
			printerr("Error loading manifest, resource type ",type," unknown.")
			return false
		
		# If Base Key does not exist, create it.
		if(!uw_data["raws"].has(base)): uw_data["raws"][base] = {}
		
		# If Name Key, and Name Key does not exist, create it.
		if(keyname != ""):
			if(!uw_data["raws"][base].has(keyname)):
				uw_data["raws"][base][keyname] = []
		
		# Load the resource type.
		var result
		type = RESOURCE_TYPES.get(type)
		match(type):
			RESOURCE_TYPES.PALETTE:
				result = palette_loader.load_palette_file(filepath)
			RESOURCE_TYPES.AUX_PALETTE:
				result = palette_loader.load_aux_palette_file(filepath)
			RESOURCE_TYPES.TEXTURE:
				result = graphics_loader.load_image_file(filepath, palette)
			RESOURCE_TYPES.GRAPHIC:
				result = graphics_loader.load_image_file(filepath, palette)
			RESOURCE_TYPES.BITMAP:
				result = graphics_loader.load_bitmap_file(filepath, palette)
			RESOURCE_TYPES.FONT:
				result = font_loader.load_font_file(filepath)
			RESOURCE_TYPES.NPC_ASSOC:
				result = npc_loader.load_assoc_file(filepath)
			RESOURCE_TYPES.NPC_ANIM:
				result = npc_loader.load_npc_anim_file(filepath)
			RESOURCE_TYPES.LEVELS:
				result = level_loader.load_levels_file(filepath)
			_:
				printerr("Error loading manifest, unhandled resource type ", type)
				tfile.close()
				return false
		
		var append_base
		if(keyname == ""):
			if(type == RESOURCE_TYPES.NPC_ANIM):
				var frame_offset = uw_data["raws"][base]["npc_animations"][anim]["frames"].size()
				for animation in result["anims"]:
					if (animation != null and frame_offset):
						var newsequence = []
						for sequence in animation:
							newsequence.push_back(sequence + frame_offset)
						animation = newsequence
					uw_data["raws"][base]["npc_animations"][anim]["anims"].push_back(animation)
				for frame in result["frames"]:
					uw_data["raws"][base]["npc_animations"][anim]["frames"].push_back(frame)
				uw_data["raws"][base]["npc_animations"][anim]["aux_pals"] = result["aux_pals"]
			else:
				uw_data["raws"][base] = result
		else:
			if(result is Array):
				uw_data["raws"][base][keyname].resize(result.size())
				for element in range(0, result.size()):
					uw_data["raws"][base][keyname][element] = result[element]
			elif (result is Dictionary):
				uw_data["raws"][base][keyname] = result
			elif (result is bool):
				printerr("Error loading resource type ", type, " from file ", filepath)
				tfile.close()
				return false
		
		print("Loaded ", result.size(), " entries of ", type," to [",base,"][", keyname,"]")
		line_counter += 1
	
	tfile.close()
	return true
