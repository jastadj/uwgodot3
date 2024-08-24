static func load_player_file(filename:String):
	
	var tfile = FileAccess.open(filename, FileAccess.READ)
	var player = {}
	
	if(tfile == null):
		print("Error opening strings file:" + filename)
		return false
	
	# skip data, TODO read all data
	tfile.seek(0x55)
	
	#0055   Int16   x-position in level
  	#0057   Int16   y-position
  	#0059   Int16   z-position
   #005B   Int8    heading (0..7?)
   #005C   Int8    dungeon level

	# get player position, direction, and dungeon level
	player["x_pos"] = int(tfile.get_16())
	player["y_pos"] = int(tfile.get_16())
	player["z_pos"] = int(tfile.get_16())
	player["dir"] = int(tfile.get_8())
	player["level"] = int(tfile.get_8())
	
	print(player)
	
	# return player
	return player
