extends Control

var aux_palettes = []
var palettes = []
var grid_rect = Rect2()

@onready var square_size = $square.texture.get_size()
@onready var index_label = $aux_palettes_container/lbl_auxpal_index
@onready var slider = $aux_palettes_container/slider_auxpal_index
@onready var grid_margin = $aux_palettes_container/MarginContainer
@onready var grid = $aux_palettes_container/MarginContainer/auxpalette_grid
@onready var cursor_info = $aux_palettes_container/lbl_cursor_info

func _init_palettes():
	
	if(!System.cur_data["raws"].has("palettes")):
		visible = false
		return
	
	_clear_palette()
	aux_palettes = []
	
	# generate palettes
	for aux_palette in System.cur_data["raws"]["palettes"]["aux"]:
		aux_palettes.append(System.generate_aux_palette(aux_palette, palettes[0]))
	
	slider.max_value = aux_palettes.size()-1
	
	draw_palette()

func _input(event):
	if (visible):
		var mouse_pos = grid.get_local_mouse_position()
		if grid_rect.has_point(mouse_pos):
			var pos = mouse_pos - grid_rect.position
			var xpos = int(pos.x/16)%4
			var ypos = int(pos.y/16)
			var index = (ypos*4) + xpos
			var color = aux_palettes[slider.value][index]
			cursor_info.text = str(index, " : ", color.r8, ",",color.g8, ",", color.b8)
		else:
			cursor_info.text = ""

func _clear_palette():
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()

func set_palettes(tpalettes):
	palettes = tpalettes
	_init_palettes()

func draw_palette():
	_clear_palette()
	index_label.text = str("Index ", slider.value, " / ", slider.max_value)
	var color_counter = 0
	for color in aux_palettes[slider.value]:
		var newsquare = $square.duplicate()
		var xpos = color_counter % 4
		var ypos = color_counter / 4
		newsquare.visible = true
		newsquare.modulate = color
		newsquare.position = Vector2(xpos, ypos) * square_size
		grid.add_child(newsquare)
		color_counter += 1
	grid_rect = Rect2(grid.position, square_size*4)
	grid_margin.custom_minimum_size = grid_rect.size
		


func _on_slider_auxpal_index_value_changed(value):
	draw_palette()
