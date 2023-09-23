extends Node

enum IMAGE_FORMAT{FMT_8BIT = 0x04, FMT_4BIT = 0x0a, FMT_4BIT_RLE = 0x08, FMT_5BIT_RLE}

static func load_image_file(filename, palette):
	var images = []
	var tfile = FileAccess.open(filename, FileAccess.READ)
	
	if(tfile == null):
		print("Error opening image file:" + filename)
		return false
	
	var format = tfile.get_8()
	var fixed_size = null
	if (format == 2): fixed_size = tfile.get_8()
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
		
		# seek to offset
		tfile.seek(offsets[i])
		
		# get image header information
		var image_type
		var color_bytes = 4
		if (format == 2):
			image_type = IMAGE_FORMAT.FMT_8BIT
			color_bytes = 3
		else: image_type = tfile.get_8()
		var width
		var height
		if(fixed_size):
			width = fixed_size
			height = fixed_size
		else:
			width = tfile.get_8()
			height = tfile.get_8()
		var aux_pal = null
		var pixel_data = []
		if (image_type == IMAGE_FORMAT.FMT_4BIT or
		image_type == IMAGE_FORMAT.FMT_4BIT_RLE ):
			aux_pal = tfile.get_8()
		var data_size
		if(format == 2): data_size = height*width
		else: data_size = tfile.get_16()
		pixel_data.resize(width*height*color_bytes)
		
		# if 8 bit uncompressed
		if (image_type == IMAGE_FORMAT.FMT_8BIT):
			for n in range(0, data_size):
				var color = palette[tfile.get_8()].to_abgr32()
				pixel_data[n*color_bytes] = color & 0xff
				pixel_data[(n*color_bytes)+1] = (color & 0xff00) >> 8
				pixel_data[(n*color_bytes)+2] = (color & 0xff0000) >> 16
				if(color_bytes == 4): pixel_data[(n*4)+3] = 0xff # alpha
		elif (image_type == IMAGE_FORMAT.FMT_4BIT):
			for n in range(0, data_size):
				var byte = tfile.get_8()
				var nibs = [(byte & 0xf0) >> 4, byte & 0xf]
				var nibn = 0
				for k in nibs:
					var color = palette[System.cur_data["palettes"]["aux"][aux_pal][k]].to_abgr32()
					pixel_data[(n*4) + nibn] = color & 0xff
					pixel_data[(n*4)+1 + nibn] = (color & 0xff00) >> 8
					pixel_data[(n*4)+2 + nibn] = (color & 0xff0000) >> 16
					pixel_data[(n*4)+3 + nibn] = 0xff # alpha
					nibn += 1
		elif (image_type == IMAGE_FORMAT.FMT_4BIT_RLE or image_type == IMAGE_FORMAT.FMT_5BIT_RLE):
			var word_size = 4
			if(image_type == IMAGE_FORMAT.FMT_5BIT_RLE): word_size = 5
			if(word_size == 4):	data_size = ceil( float(data_size) / 2.0)
			# create bitstream
			var bit_stream = []
			for b in range(0, data_size):
				var byte = tfile.get_8()
				for n in range(0, 8):
					bit_stream.append( (byte & (0x1 << 7-n)) >> (7-n) )
			var atom_map = decode_rle_bitstream(word_size, bit_stream)
			if(atom_map.size() > width*height): atom_map.resize(width*height)
			# use the atom map to map the aux palette indices to colors into the pixel data array
			for n in range(0, atom_map.size()):
				var color = palette[System.cur_data["palettes"]["aux"][aux_pal][atom_map[n]]].to_abgr32()
				pixel_data[(n*4)] = color & 0xff
				pixel_data[(n*4)+1] = (color & 0xff00) >> 8
				pixel_data[(n*4)+2] = (color & 0xff0000) >> 16
				pixel_data[(n*4)+3] = 0xff

			
		else:
			printerr("Error loading graphics file ", filename, " at offset ", offsets[i], " : unrecognized image type ", image_type)
			return false
		
		# done
		var image_format
		if(color_bytes == 3): image_format = Image.FORMAT_RGB8
		else: image_format = Image.FORMAT_RGBA8
		var image = Image.create_from_data(width, height, false, image_format, pixel_data)
		images.append(image)
			
	return images

static func decode_rle_bitstream(word_size:int, bits:Array):
	var repeat_mode = true
	var atom_map = []
	
	# decode bits
	while (bits.size() > 0):
		
		# get a count
		var count = rle_get_count(bits)
		
		# repeat mode
		if (repeat_mode):
			# if count == 1, skip this record and do a run
			if (count == 1):
				repeat_mode = false
				continue
			# if count == 2, perform multiple repeats
			elif (count == 2):
				var repeats = rle_get_count(bits)
				while repeats > 0:
					count = rle_get_count(bits)
					var value = rle_extract_word(bits, word_size)
					while count > 0:
						atom_map.append(value)
						count -= 1
					repeats -= 1
			else:
				var val = rle_extract_word(bits, word_size)
				for n in range(0, count):
					atom_map.append(val)
		# run mode
		else:
			for i in range(0, count):
				atom_map.append(rle_extract_word(bits, word_size))
		repeat_mode = !repeat_mode
	
	return atom_map;

static func rle_get_count(bits:Array):
	var count = rle_extract_word(bits, 4)
	# if count == 0, get two more nibbles
	if (!count):
		count = rle_extract_word(bits, 8)
		# if count is still == 0, get three more nibbles
		if(!count):
			count = rle_extract_word(bits, 12)
	return count

static func rle_extract_word(bits:Array, word_size:int):
	var val = 0
	if(bits.size() == 0 or bits.size() < word_size): return val
	for i in range(0, word_size):
		val = (val << 1) | bits[0]
		bits.pop_front()
	return val
