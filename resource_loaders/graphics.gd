extends Node

enum IMAGE_FORMAT{FMT_8BIT = 0x04, FMT_4BIT = 0x0a, FMT_4BIT_RLE = 0x08, FMT_5BIT_RLE}

static func load_texture_file(filename):
	var textures = []
	var tfile = FileAccess.open(filename, FileAccess.READ)
	var palette0 = System.cur_data["palettes"]["main"][0]
	if(tfile == null):
		print("Error opening texture file:" + filename)
		return false
	
	while !tfile.eof_reached():
		# Read Header
		var _format = tfile.get_8()
		var size = tfile.get_8()
		var count = tfile.get_16()
		var offsets = []
		for i in range(0, count):
			offsets.append(tfile.get_32())
		
		# Create Image from Data at Offsets
		for offset in offsets:
			tfile.seek(offset)
			var image_data = [] # width*height*(3-byte rgb)
			image_data.resize(size*size*3)
			for i in range(0, size*size):
				var color = palette0[tfile.get_8()].to_abgr32()
				image_data[i*3] = color & 0xff
				image_data[(i*3)+1] = (color & 0xff00) >> 8
				image_data[(i*3)+2] = (color & 0xff0000) >> 16
			var image = Image.create_from_data(size, size, false, Image.FORMAT_RGB8, image_data)
			textures.append(image)
	
	tfile.close()
	return textures

static func load_graphics_file(filename, palette):
	var graphics = []
	var tfile = FileAccess.open(filename, FileAccess.READ)
	
	if(tfile == null):
		print("Error opening graphics file:" + filename)
		return false
	
	var _format = tfile.get_8()
	var image_count = tfile.get_16()
	var offsets = []
	# get offsets
	for i in range(0, image_count):
		offsets.append(tfile.get_32())
	
	# read in image at offsets
	# an image record is null if:
	# 	offsets are duplicate
	#	offsets are out of range
	for i in range(0, offsets.size()):
		
		# check for null record
		if (i > 0):
			if (offsets[i] == offsets[i-1]): continue
			elif (offsets[i] >= tfile.get_length()): continue
		
		tfile.seek(offsets[i])
		var image_type = tfile.get_8()
		var width = tfile.get_8()
		var height = tfile.get_8()
		var aux_pal = null
		var pixel_data = []
		if (image_type == IMAGE_FORMAT.FMT_4BIT or
		image_type == IMAGE_FORMAT.FMT_4BIT_RLE ):
			aux_pal = tfile.get_8()
		var data_size = tfile.get_16()
		pixel_data.resize(width*height*4)
		
		# if 8 bit uncompressed
		if (image_type == IMAGE_FORMAT.FMT_8BIT):
			for n in range(0, data_size):
				var color = palette[tfile.get_8()].to_abgr32()
				pixel_data[n*4] = color & 0xff
				pixel_data[(n*4)+1] = (color & 0xff00) >> 8
				pixel_data[(n*4)+2] = (color & 0xff0000) >> 16
				pixel_data[(n*4)+3] = 0xff # alpha
		elif (image_type == IMAGE_FORMAT.FMT_4BIT):
			for n in range(0, data_size):
				var byte = tfile.get_8()
				var nibs = [(byte & 0xf0) >> 4, byte & 0xf]
				var nibn = 0
				for k in nibs:
					var color = palette[System.cur_data["palettes"]["aux"][aux_pal][k]]
					pixel_data[(n*4) + nibn] = color & 0xff
					pixel_data[(n*4)+1 + nibn] = (color & 0xff00) >> 8
					pixel_data[(n*4)+2 + nibn] = (color & 0xff0000) >> 16
					pixel_data[(n*4)+3 + nibn] = 0xff # alpha
					nibn += 1
		elif (image_type == IMAGE_FORMAT.FMT_4BIT_RLE or image_type == IMAGE_FORMAT.FMT_5BIT_RLE):
			
			var bits = 4
			if(image_type == IMAGE_FORMAT.FMT_5BIT_RLE): bits = 5
			
			if(bits == 4):
				data_size = ceil(data_size / 2)
			
			pixel_data.fill(0xff)
			
		else:
			printerr("Error loading graphics file ", filename, " at offset ", offsets[i], " : unrecognized image type ", image_type)
			return false
		
		# done
		var image = Image.create_from_data(width, height, false, Image.FORMAT_RGBA8, pixel_data)
		graphics.append(image)
			
	return graphics
