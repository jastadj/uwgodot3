extends Node2D

@onready var palette_grid = $palette_grid
@onready var pal_color = $pal_0
@onready var native_size = pal_color.get_rect().size
@onready var palettes = System.cur_data["palettes"]["main"]
@onready var slider = $ui/VBoxContainer/HSlider
@onready var current_label = $ui/VBoxContainer/current_palette
@onready var palette_cursor = $ui/palette_cursor

var palette_index = 0
var grid_rect = Rect2()

func _ready():
	visible = false
	slider.value = palette_index
	slider.max_value = palettes.size()-1
	
	connect("visibility_changed", _on_visibility_changed)

func _process(_delta):
	
	if(visible):
		var mouse_pos = get_local_mouse_position()
		if (grid_rect.has_point(mouse_pos)):
			var xpos = int((mouse_pos.x - grid_rect.position.x)/16)
			var ypos = int((mouse_pos.y - grid_rect.position.y)/16)
			var index = (ypos*16) + xpos
			var color = palettes[palette_index][index]
			palette_cursor.text = str("Index: ", index, " Color:",color.r8, ",", color.g8, ",", color.b8 )
		else: palette_cursor.text = "Index: ---"
			
func _on_visibility_changed():
	if(visible): draw_palette()
	
func clear_palette_grid():
	for child in palette_grid.get_children():
		palette_grid.remove_child(child)
		child.queue_free()

func draw_palette():
	current_label.text = str("Palette ", palette_index, " / ", palettes.size()-1)
	clear_palette_grid()
	
	for i in range(0, palettes[palette_index].size()):
		var color = pal_color.duplicate()
		color.visible = true
		color.modulate = palettes[palette_index][i]
		palette_grid.add_child(color)
		color.position = Vector2( (i%16)*native_size.x, (i/16)*native_size.y)
		
	grid_rect = Rect2(palette_grid.position, native_size*16)


func _on_h_slider_value_changed(value):
	palette_index = slider.value
	draw_palette()
