static func load_assoc_file(filename:String):
	var tfile = FileAccess.open(filename, FileAccess.READ)
	var npcs = {"npc":[], "npc_animations":[]}
	
	if(tfile == null):
		print("Error opening assoc file:" + filename)
		return false
	
	# get animation type names
	for i in range(0,32):
		var animname = ""
		for b in range(0,8):
			var byte = tfile.get_8()
			animname += char(byte)
		animname = animname.rstrip("0")
		npcs["npc_animations"].push_back({"name":animname, "anims":[], "frames":[], "aux_pals":[]})
	
	# get animation type and auxpal used for npcs (all 64 npc types)
	for i in range(0,64):
		npcs["npc"].push_back({"anim":tfile.get_8(), "aux_pal":tfile.get_8()})
	
	return npcs

static func load_npc_anim_file(filename:String):
	var tfile = FileAccess.open(filename, FileAccess.READ)
	var image_loader = load("res://resource_loaders/graphics.gd")
	
	if(tfile == null):
		print("Error opening assoc file:" + filename)
		return false
		
	var anim_start_index = tfile.get_8()
	var anim_count = tfile.get_8()
	var anim_indices = []
	var valid_anim_count = 0
	var anims = []
	var aux_pal_count
	var aux_palettes = []
	var frame_offset_count
	var frame_compression_type
	var frame_offsets = []
	var frames = []
	
	# get the animation indices
	tfile.get_8() # not sure what this byte is for?
	for i in range(0, anim_count):
		var aindex = tfile.get_8()
		# invalid anim slots are 0xff
		if (aindex == 0xff): aindex = null
		else: valid_anim_count += 1
		anim_indices.push_back(aindex)
		
	# get the animation frame indices (8 frames per anim)
	for i in range(0, valid_anim_count):
		var frame_indices = []
		for n in range(0, 8):
			var frame_index = tfile.get_8()
			# unused frames padded with 0xff
			if(frame_index != 0xff): frame_indices.push_back(frame_index)
		anims.push_back(frame_indices)
	
	# get the aux palettes (32)
	aux_pal_count = tfile.get_8()
	for i in range(0,aux_pal_count):
		var auxpal = []
		for n in range(0,32):
			auxpal.push_back(tfile.get_8())
		aux_palettes.push_back(auxpal)
	
	# get the frame offsets
	frame_offset_count = tfile.get_8()
	frame_compression_type = tfile.get_8()
	for i in range(0, frame_offset_count):
		frame_offsets.push_back(tfile.get_16())
	
	# get frame data at each offset
	for foffset in frame_offsets:
		var animation_frame = {}
		var bytecount
		var wordsize = null
		var bitstream_pixels = []
		var width = tfile.get_8()
		var height = tfile.get_8()
		var type
		var data_size
		animation_frame["x"] = tfile.get_8()
		animation_frame["y"] = tfile.get_8()
		type = tfile.get_8()
		animation_frame["image"] = System.new_image(type, 0)
		animation_frame["image"]["width"] = width
		animation_frame["image"]["height"] = height
		if(type == System.IMAGE_FORMAT.FMT_5BIT_RLE): wordsize = 5
		elif(type == System.IMAGE_FORMAT.FMT_4BIT_RLE): wordsize = 4
		data_size = tfile.get_16()
		bytecount = ceil(float(data_size * wordsize) / 8.0)
		# read bytes in as a bitstream and uncompress
		for b in range(0, bytecount):
			var byte = tfile.get_8()
			for n in range(0, 8):
				bitstream_pixels.append( (byte & (0x1 << 7-n)) >> (7-n) )
		var uncompressed_pixel_data = image_loader.decode_rle_bitstream(wordsize, bitstream_pixels)		
		# shear off junk byte
		uncompressed_pixel_data.resize(height*width)
		animation_frame["image"]["data"] = uncompressed_pixel_data
		frames.push_back(animation_frame)
	
	# build animation data
	var animation_data = {
	"anims":[],
	"frames":frames,
	"aux_pals":aux_palettes
	}
	for i in range(0, anim_indices.size()):
		if(anim_indices[i] != null):
			animation_data["anims"].push_back(anims[anim_indices[i]-1])
		else: animation_data["anims"].push_back(null)
	
	return animation_data
	
