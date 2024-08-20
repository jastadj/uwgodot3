extends Node3D

var floor_textures = []
var wall_textures = []
#$tiles/floor/Plane.get_active_material(0).set_shader_parameter("img", ImageTexture.create_from_image(System.cur_data["images"]["floor_32"][0]) )

func _ready():
	
	# main palette
	var palette = System.generate_palette(System.cur_data["raws"]["palettes"]["main"][0])
	
	# init floor textures
	for entry in System.cur_data["raws"]["images"]["floor_32"]:
		floor_textures.push_back(ImageTexture.create_from_image(System.generate_image_from_image_entry(entry, palette, null)))
	
	# init wall textures
	for entry in System.cur_data["raws"]["images"]["walls_64"]:
		wall_textures.push_back(ImageTexture.create_from_image(System.generate_image_from_image_entry(entry, palette, null)))
	
	#testing
	#$floor/Plane.get_active_material(0).set_shader_parameter("img", ImageTexture.create_from_image(System.cur_data["images"]["floor_32"][0]) )
	
func load_level(level:Dictionary):
		
	clear_level()
	
	#print(level.keys())
	#print(level["textures"].keys())
	#print(level["textures"]["ceiling"])
	#print(level["tiles"][2])
	
	# ceiling texture index
	var ceiling_texture_index = level["textures"]["ceiling"]
	
	for y in range(0, level["length"]):
		var new_nodey = Node3D.new()
		new_nodey.name = str("y_",y)
		$tiles.add_child(new_nodey)
		for x in range(0, level["width"]):
			var new_nodex = preload("res://level_cell/level_cell.tscn").instantiate()
			var floor_texture_index = level["textures"]["floors"][level["tiles"][y][x]["floor"]]
			var wall_texture_index = level["textures"]["walls"][level["tiles"][y][x]["wall"]]
			
			new_nodex.name = str("x_",x)
			new_nodey.add_child(new_nodex)
			new_nodex.position = Vector3(x*System.TILE_SIZE, 0, (y-level["length"])*System.TILE_SIZE)
			
			# get references to adjacent cells
			if(x != 0):
				var west_cell = new_nodey.get_node(str("x_",x-1))
				new_nodex.west = west_cell
				west_cell.east = new_nodex
			if(y != 0):
				var north_cell = $tiles.get_node(str("y_", y-1))
				if north_cell:
					north_cell = north_cell.get_node(str("x_",x))
				new_nodex.north = north_cell
				north_cell.south = new_nodex
							
			new_nodex.set_cell(level["tiles"][y][x]["type"], level["tiles"][y][x]["height"], floor_textures[floor_texture_index], wall_textures[wall_texture_index], floor_textures[ceiling_texture_index])
			
	
func clear_level():
	pass
