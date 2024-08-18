extends Node3D

var floor_textures = []
var wall_textures = []

var height = 0
var floor_texture = null
var wall_texture = null
var ceiling_texture = null
var cell_type = System.TILE_TYPES.SOLID

var target_cell

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var palette = System.generate_palette(System.cur_data["raws"]["palettes"]["main"][0])
	
	# init floor textures
	for entry in System.cur_data["raws"]["images"]["floor_32"]:
		floor_textures.push_back(ImageTexture.create_from_image(System.generate_image_from_image_entry(entry, palette, null)))
		$CanvasLayer/ui/floor_texture_list.add_icon_item(floor_textures.back())
		
	# init wall textures
	for entry in System.cur_data["raws"]["images"]["walls_64"]:
		wall_textures.push_back(ImageTexture.create_from_image(System.generate_image_from_image_entry(entry, palette, null)))
		$CanvasLayer/ui/wall_texture_list.add_icon_item(wall_textures.back())
	
	# all cells share the same ceiling texture
	ceiling_texture = floor_textures[15]
	
	# create level cells
	var default_height = 8*4
	for y in range(0, 5):
		for x in range(0, 5):
			
			# create cell
			var new_cell = preload("res://level_cell/level_cell.tscn").instantiate()
			new_cell.name = str(x,"_",y)
			new_cell.position = Vector3(x*System.TILE_SIZE, 0, y*System.TILE_SIZE)
			$level.add_child(new_cell)
			
			# if this is the target cell (middle), get reference
			if(y == 2 and x == 2):
				target_cell = new_cell
			
			# connect adjacent cell references
			if y > 0:
				new_cell.north = $level.get_node(str(x,"_",y-1))
				if new_cell.north:
					new_cell.north.south = new_cell
			if x > 0:
				new_cell.west = $level.get_node(str(x-1,"_",y))
				if new_cell.west:
					new_cell.west.east = new_cell
			
			# set cells
			if( y == 0 or y == 4 or x == 0 or x == 4):
				new_cell.set_cell(System.TILE_TYPES.SOLID, default_height, null, null, null)
			else:
				new_cell.set_cell(System.TILE_TYPES.OPEN, default_height, floor_textures[0], wall_textures[0], ceiling_texture)
	
	set_floor_texture(floor_textures[1])
	set_wall_texture(wall_textures[12*4])
	set_floor_type(System.TILE_TYPES.OPEN)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_back_pressed():
	get_tree().change_scene_to_file("res://scenes/tempmain/tempmain.tscn")

func update_target_cell():
	target_cell.set_cell(cell_type, height, floor_texture, wall_texture, ceiling_texture)

func set_floor_texture(target_floor_texture):
	floor_texture = target_floor_texture
	$CanvasLayer/ui/HFlowContainer/TextureButtonFloor.texture_normal = floor_texture
	update_target_cell()

func set_wall_texture(target_wall_texture):
	wall_texture = target_wall_texture
	$CanvasLayer/ui/HFlowContainer/TextureButtonWall.texture_normal = wall_texture
	update_target_cell()

func set_floor_type(type:System.TILE_TYPES):
	cell_type = type
	$CanvasLayer/ui/HFlowContainer/OptionButtonTypes.select(cell_type)
	update_target_cell()

func _on_texture_button_floor_button_up():
	$CanvasLayer/ui/floor_texture_list.show()

func _on_floor_texture_list_item_selected(index):
	$CanvasLayer/ui/floor_texture_list.hide()
	set_floor_texture(floor_textures[index])

func _on_option_button_types_item_selected(index):
	set_floor_type(index)

func _on_wall_texture_list_item_selected(index):
	$CanvasLayer/ui/wall_texture_list.hide()
	set_wall_texture(wall_textures[index])

func _on_texture_button_wall_button_up():
	$CanvasLayer/ui/wall_texture_list.show()

func _on_h_slider_height_value_changed(value):
	height = value
	update_target_cell()
