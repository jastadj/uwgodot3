extends Control

@onready var level_selector = $VBoxContainer/HBoxContainer/spinbox_level
@onready var label_width = $VBoxContainer/label_width
@onready var label_length = $VBoxContainer/label_length

var cur_level
var palette
var floor_textures = []
@onready var tile_size = $square.texture.get_size()
@onready var tiles = $tiles
@onready var objects = $objects
var tile_cursor
var tile_shader = load("res://scenes/debug/raw_resource_viewers/components/level_tile.gdshader")

var rmb_clicked_at = Vector2(0,0)
var tiles_clicked_position
var panning = false

func _ready():
	
	# init palette0
	palette = System.generate_palette(System.cur_data["raws"]["palettes"]["main"][0])
	
	# init floor textures
	for entry in System.cur_data["raws"]["images"]["floor_16"]:
		floor_textures.push_back(System.generate_image_from_image_entry(entry, palette, null))
	
	level_selector.max_value = System.cur_data["raws"]["levels"].size()
	level_selector.min_value = 1
	
	# create tilec cursor
	tile_cursor = $square.duplicate()
	tile_cursor.visible = true
	tile_cursor.modulate = Color(0,1,0,0.25)
	add_child(tile_cursor)
	
func _process(_delta):
	
	var tilescale = tiles.scale
	var mouse_pos = (get_global_mouse_position() - tiles.position)
	
	mouse_pos = Vector2( int((mouse_pos.x)/(tile_size.x*tilescale.x)), int(mouse_pos.y/(tile_size.y*tilescale.y)))
	tile_cursor.position = (mouse_pos*tile_size*tilescale) + tiles.position
	tile_cursor.scale = tiles.scale
	
	$LabelCursorPos.text = str(mouse_pos.x,",",cur_level["length"] - mouse_pos.y)

func _input(event):
	
	if !visible:
		return
	
	if event is InputEventMouseButton:
		if event.pressed:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				rmb_clicked_at = get_global_mouse_position()
				tiles_clicked_position = tiles.position
				panning = true
			elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var mouse_pos = get_global_mouse_position()
				tiles.scale = tiles.scale * 2
				tiles.position += (tiles.position - mouse_pos)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var mouse_pos = get_global_mouse_position()
				tiles.scale = tiles.scale / 2
				tiles.position -= (tiles.position - mouse_pos)/2
		else:
			if event.button_index == MOUSE_BUTTON_RIGHT:
				panning = false
	elif event is InputEventMouseMotion:
		if panning:
			tiles.position = tiles_clicked_position + get_global_mouse_position() - rmb_clicked_at

func _select_level(level_num):
	cur_level = System.cur_data["raws"]["levels"][level_num]
	label_width.text = str("Width:", cur_level["tiles"][0].size())
	label_length.text = str("Length:", cur_level["tiles"].size())
	
	_update_tiles()
	
func _update_tiles():
	_clear_level()
	tiles.position = Vector2(0,0)
	for y in range(0, cur_level["length"]):
		for x in range(0, cur_level["width"]):
			var newtile = $square.duplicate()
			var floor_index = cur_level["textures"]["floors"][cur_level["tiles"][y][x]["floor"]]
			newtile.position = Vector2(x,y) * tile_size
			newtile.visible = true
			newtile.material = ShaderMaterial.new()
			newtile.material.shader = tile_shader
			newtile.material.set_shader_parameter("tile_type", cur_level["tiles"][y][x]["type"])
			newtile.texture = ImageTexture.create_from_image(floor_textures[floor_index])
			tiles.add_child(newtile)
	
func _clear_level():
	for child in tiles.get_children():
		tiles.remove_child(child)
		child.queue_free()
		
	for child in objects.get_children():
		objects.remove_child(child)
		child.queue_free()


func _on_visibility_changed():
	if(visible): _select_level(level_selector.value-1)


func _on_spinbox_level_value_changed(value):
	_select_level(level_selector.value-1)
