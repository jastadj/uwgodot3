extends Control

var palettes = []
var grid_rect = Rect2()

@onready var square_size = $square.texture.get_size()
@onready var slider = $palettecontainer/slider_pal_index
@onready var grid = $palettecontainer/palette_grid
@onready var index_label = $palettecontainer/lbl_pal_index
@onready var cursor_info = $palettecontainer/lbl_cursor_info

func _ready():
	
	# generate palettes
	for palette in System.cur_data["raws"]["palettes"]["main"]:
		var color_list = []
		for color in palette:
			color_list.append(Color(color[0], color[1], color[2]))
		palettes.append(color_list)
	
	slider.max_value = palettes.size()-1
	
	draw_palette()

func _input(event):
	if (visible):
		var mouse_pos = get_local_mouse_position()
		if grid_rect.has_point(mouse_pos):
			var pos = mouse_pos - grid_rect.position
			var xpos = int(pos.x/16)%16
			var ypos = int(pos.y/16)
			var index = (ypos*16) + xpos
			var color = palettes[slider.value][index]
			cursor_info.text = str(index, " : ", color.r8, ",",color.g8, ",", color.b8)
		else:
			cursor_info.text = ""

func _clear_palette():
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	
func draw_palette():
	_clear_palette()
	index_label.text = str("Index ", slider.value, " / ", slider.max_value)
	var color_counter = 0
	for color in palettes[slider.value]:
		var newsquare = $square.duplicate()
		var xpos = color_counter % 16
		var ypos = color_counter / 16
		newsquare.visible = true
		newsquare.modulate = color
		newsquare.position = Vector2(xpos, ypos) * square_size
		grid.add_child(newsquare)
		color_counter += 1
	grid_rect = Rect2(grid.position, square_size*16)


func _on_slider_pal_index_value_changed(value):
	draw_palette()
