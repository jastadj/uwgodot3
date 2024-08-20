static func load_strings_file(filename:String):
	
	var tfile = FileAccess.open(filename, FileAccess.READ)
	var strings = []
	
	if(tfile == null):
		print("Error opening strings file:" + filename)
		return false
	return strings
