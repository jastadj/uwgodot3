static func load_levels_file(filename:String):
	var tfile = FileAccess.open(filename, FileAccess.READ)
	var levels = []
	
	if(tfile == null):
		print("Error opening levels file:" + filename)
		return false
	
	return levels
