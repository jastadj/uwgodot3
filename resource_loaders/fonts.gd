static func load_font_file(filename:String):
	var tfile = FileAccess.open(filename, FileAccess.READ)
	
	if(tfile == null):
		print("Error opening font file:" + filename)
		return false
	
	var font_width_bytes = tfile.get_16()
	var char_size_bytes = tfile.get_16()
	var space_width_px = tfile.get_16()
	var font_height_px = tfile.get_16()
	var row_bytes = tfile.get_16()
	var max_width_px = tfile.get_16()
	var char_count = tfile.get_length() / (char_size_bytes+1)
	var chars = []
	var new_font = System.new_font(space_width_px, font_height_px, max_width_px)
	
	for i in range(0, char_count):
		var newchar
		var rowdata = []
		var char_width_px
		# read in bytes for each font row
		for row in range(0, font_height_px):
			var rowbits = 0
			for b in range(0, row_bytes):
				rowbits = rowbits | (tfile.get_8() << (b*8) )
			rowdata.append(rowbits)
		char_width_px = tfile.get_8()
		newchar = {"width":char_width_px, "char":[]}
		
		# resize font rows
		for k in range(0, rowdata.size()):
			rowdata[k] = rowdata[k] >> ((row_bytes*8) - char_width_px)
		newchar["char"] = rowdata
		chars.append(newchar)
			
	new_font["data"] = chars
	new_font["lowercase"] = (chars.size() >= 122 )
	return new_font
	
	
	
	
	
