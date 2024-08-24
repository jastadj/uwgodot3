static func load_levels_file(filename:String):
	
	var tfile = FileAccess.open(filename, FileAccess.READ)
	var levels = []
	# the following variables are for uw1 only
	var level_count = 9
	var level_width = 64
	var level_length = 64
	
	if(tfile == null):
		print("Error opening levels file:" + filename)
		return false
		
	var block_count = tfile.get_16()
	var block_offsets = []
	for i in range(0, block_count):
		block_offsets.push_back(tfile.get_32())
	
	# resize / create level entries
	for i in range(0, level_count):
		levels.push_back({"width":level_width, "length":level_length})
	
	# read tilemap / object index block for each level
	for level_num in range(0, level_count):
		# move to block offset
		tfile.seek(block_offsets[(level_count*0)+level_num])
		
		var tilemap = []
		tilemap.resize(level_length)
		
		# read in 4 bytes for each tile (width*length*4)
		for y in range(0, level_length):
			tilemap[y] = []
			for x in range(0, level_width):
				var data1 = tfile.get_16()
				var data2 = tfile.get_16()
				
				# data 1 - tile properties / flag bits
				var tile_type = data1 & 0xf
				var tile_height = (data1 & 0xf0) >> 1 # this value is >> 4 then << 3 for 0-127 height conversion
				# bits 8 and 9 are unk
				var floor_texture_index = (data1 & 0x3c00) >> 10
				var flag_no_magic = bool((data1 & 0x4000) >> 14)
				var flag_door = bool((data1 & 0x8000) >> 15)
				
				# data 2 - wall texture and object list info
				var wall_texture_index = (data2 & 0x3f)
				var object_index_offset = (data2 & 0xffc0) >> 6
				var tile = {"x":x, "y":y, "type":tile_type, "height":tile_height, "floor":floor_texture_index, "wall":wall_texture_index,"flag_no_magic":flag_no_magic, "flag_door":flag_door, "object_offset":object_index_offset }
				tilemap[y].push_back(tile)
		tilemap.reverse()
		levels[level_num]["tiles"] = tilemap
	
		# read object list for each level
		var objects = []
		
		# read mobile objects
		for npc_index in range(0, 256):
			var npc = _read_object_info(tfile)
			npc["npc"] = _read_npc_info(tfile)
			objects.append(npc)
	
		# read objects
		for object_index in range(0, 768):
			var object = _read_object_info(tfile)
			objects.append(object)
		
		# read free object lists and set object index to null (free slot)
		# the npc free is list only 254 entries (-2 for 0=null, 1=avatar)
		for free_npc_index in range(0,254):
			objects[tfile.get_16()] = null
		# read free list for objects
		for free_object_index in range(0,768):
			objects[tfile.get_16()] = null
		
		levels[level_num]["objects"] = objects
		
		# for each tile, walk through the object linked list
		# and adjust the tile position values to global position
		for tile_y in tilemap:
			for tile in tile_y:
				var object = objects[tile["object_offset"]]
				while object != null and object != objects[0]:
					#print("tile:(", tile["x"], ",", tile["y"], ") object id:", object["id"], " (", object["x"], ",", object["y"], ",", object["z"], ")")
					object["x"] += tile["x"]*8
					object["y"] += tile["y"]*8
					object = objects[object["next_object"]]
		
	# read anim info block
	for level_num in range(0, level_count):			
		# move to block offset
		tfile.seek(block_offsets[(level_count*1)+level_num])
		
		var anim_info = []
		
		for anim_index in range(0, 64):
			var anim_entry = {}
			var data1 = tfile.get_16()
			var object_index_link = (data1 & 0xffc0) >> 6
			# unused bits?
			anim_entry["object_link"] = object_index_link
			
			tfile.get_16() # unk
			
			var x = tfile.get_8()
			var y = tfile.get_8()
			anim_entry["x"] = x
			anim_entry["y"] = y
			anim_info.push_back(anim_entry)
		levels[level_num]["anims"] = anim_info
	
	# read texture map blocks
	for level_num in range(0, level_count):			
		# move to block offset
		tfile.seek(block_offsets[(level_count*2)+level_num])
		
		var textures = {"walls":[], "floors":[], "doors":[], "ceiling":0}
		
		# walls
		for i in range(0, 48):
			textures["walls"].push_back(tfile.get_16())
		# floors
		for i in range(0,10):
			textures["floors"].push_back(tfile.get_16())
		# doors
		for i in range(0, 6):
			textures["doors"].push_back(tfile.get_8())
		# last floor texture is the ceiling
		textures["ceiling"] = textures["floors"].back()
		
		levels[level_num]["textures"] = textures
	
	print(levels[0].keys())
	return levels

static func _read_object_info(tfile:FileAccess):
	
	var object = {}
	
	var data1 = tfile.get_16()
	var data2 = tfile.get_16()
	var data3 = tfile.get_16()
	var data4 = tfile.get_16()
	
	# object id / flags
	var id = data1 & 0x1ff
	var flags = (data1 & 0x1e00) >> 9
	var flag_enchant = bool((data1 & 0x1000) >> 12)
	var flag_door_dir = bool((data1 & 0x2000) >> 13)
	var flag_invisible = bool((data1 & 0x4000) >> 14)
	var flag_is_quantity = bool((data1 & 0x8000) >> 15)
	var texture_index = (data1 & 0xfe00) >> 9
	
	# object position
	var z = (data2 & 0x7f)
	var angle = (data2 & 0x380) >> 7
	var y = (data2 & 0x1c00) >> 10
	var x = (data2 & 0xe000) >> 13
	
	# quality / linked list next
	var quality = (data3 & 0x3f)
	var next_object = (data3 & 0xffc0 ) >> 6
#
	# special
	var special1 = (data4 & 0x3f)
	var special2 = (data4 & 0xffc0) >> 6
	
	object["id"] = id
	object["flags"] = flags
	object["flag_enchant"] = flag_enchant
	object["flag_door_dir"] = flag_door_dir
	object["flag_invisible"] = flag_invisible
	object["flag_quantity"] = flag_is_quantity
	object["texture_index"] = texture_index
	object["z"] = z
	object["x"] = x
	object["y"] = y
	object["angle"] = angle
	object["quality"] = quality
	object["next_object"] = next_object
	object["special1"] = special1
	object["special2"] = special2
	object["npc"] = null
	return object
	
static func _read_npc_info(tfile:FileAccess):
	var npc = {}
	
	var hp = tfile.get_8()
	npc["hp"] = hp
	
	tfile.get_8() # unk
	
	tfile.get_8() # unk
	
	var data1 = tfile.get_16()
	var goal = (data1 & 0xf)
	var target = (data1 & 0xff0) >> 4
	npc["goal"] = goal
	npc["target"] = target
	# other bits?
	
	var data2 = tfile.get_16()
	var level = (data2 & 0xf)
	var talked_to = bool((data2 & 0x2000) >> 13)
	var attitude = (data2 & 0xc000) >> 14
	npc["level"] = level
	npc["talked_to"] = talked_to
	npc["attitude"] = attitude
	# other bits?
	
	var data3 = tfile.get_16()
	var height = (data3 & 0x1fc0) >> 6
	npc["height"] = height
	# other bits?
	
	tfile.get_8() # unk
	
	tfile.get_8() # unk
	
	tfile.get_8() # unk - single bit
	
	tfile.get_8() # unk
	
	tfile.get_8() # unk
	
	var data4 = tfile.get_16()
	var home_y = (data4 & 0x3f0 ) >> 4
	var home_x = (data4 & 0xfc00) >> 10
	npc["home_y"] = home_y
	npc["home_x"] = home_x
	# other bits?
	
	var data5 = tfile.get_8()
	var heading = (data4 & 0xf)
	npc["heading"] = heading
	# other bits?
	
	var data6 = tfile.get_8()
	var hunger = (data6 & 0x7f)
	npc["hunger"] = hunger
	# other bits?
	
	var id = tfile.get_8()
	npc["id"] = id
	
	return npc
