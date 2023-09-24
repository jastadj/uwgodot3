extends Node

static func load_palette_file(filename):
	
	var palettes = []
	var pfile = FileAccess.open(filename, FileAccess.READ)
	if(pfile == null):
		print("Error opening palette file:" + filename)
		return false
	
	while !pfile.eof_reached():
		var cur_pal = []
		for i in range(0, 256):
			var r = float(pfile.get_8())/64
			var g = float(pfile.get_8())/64
			var b = float(pfile.get_8())/64
			cur_pal.append([r, g, b])
		
		if (cur_pal.size() == 256):
			palettes.append(cur_pal)
		else: print("Rejecting incomplete palette of size ", cur_pal.size())
	
	pfile.close()
	return palettes

static func load_aux_palette_file(filename):
	var aux_palettes = []
	var pfile = FileAccess.open(filename, FileAccess.READ)
	if(pfile == null):
		print("Error opening aux palette file:" + filename)
		return false
	
	while !pfile.eof_reached():
		var cur_pal = []
		for i in range(0, 16):
			cur_pal.append(pfile.get_8())
		
		if (cur_pal.size() == 16):
			aux_palettes.append(cur_pal)
		else: print("Rejecting incomplete palette of size ", cur_pal.size())
	pfile.close()
	return aux_palettes
