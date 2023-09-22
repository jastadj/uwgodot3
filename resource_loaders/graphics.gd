extends Node

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
	
	return textures

static func load_graphics_file(filename):
	pass
