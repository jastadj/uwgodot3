extends Node2D

@onready var palette_0 = System.cur_data["palettes"]["main"][0]
@onready var aux_palettes = System.cur_data["palettes"]["aux"]
@onready var index_label = $ui/VBoxContainer/label_index
@onready var cursor_info = $ui/label_cursor
@onready var grid = $grid
@onready var slider = $ui/VBoxContainer/slider

var square_size
var grid_rect = Rect2()
var aux_index = 0

func _ready():
	visible = false
	connect("visibility_changed", _on_visibility_changed)
	slider.value = aux_index
	slider.max_value = aux_palettes.size()-1
	square_size = $square.texture.get_size()

func _process(_delta):
	
	if(visible):
		var mouse_pos = get_local_mouse_position()
		if (grid_rect.has_point(mouse_pos)):
			var xpos = int((mouse_pos.x - grid_rect.position.x)/16)
			var ypos = int((mouse_pos.y - grid_rect.position.y)/16)
			var index = (ypos*4) + xpos
			var color = palette_0[aux_palettes[aux_index][index]]
			cursor_info.text = str("Index: ", index, " Color:",color.r8, ",", color.g8, ",", color.b8 )
		else: cursor_info.text = "Index: ---"

func _on_visibility_changed():
	if(visible): draw_aux_palette()

func _clear_grid():
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()

func draw_aux_palette():
	_clear_grid()
	index_label.text = str("Aux Palette ", aux_index, " / ", aux_palettes.size()-1)
	for i in range(0, aux_palettes[aux_index].size()):
		var color = $square.duplicate()
		color.visible = true
		color.modulate = palette_0[aux_palettes[aux_index][i]]
		grid.add_child(color)
		color.position = Vector2( (i%4)*square_size.x, (i/4)*square_size.y)		
	
	grid_rect = Rect2(grid.position, square_size*4)


func _on_slider_value_changed(value):
	aux_index = slider.value
	draw_aux_palette()
