extends PanelContainer

@onready var grid = $VBoxContainer/GridContainer
@onready var label_palette = $VBoxContainer/label_palette

var palettes = null

var current_palette_index = 0

func _ready():
	
	palettes = System.cur_data["palettes"]["main"]
	
	draw_palette()

func _input(event):
	
	if(has_focus()):
		if event.is_action_pressed("ui_left"):
			current_palette_index -= 1
			draw_palette()
		elif event.is_action_pressed("ui_right"):
			current_palette_index += 1
			draw_palette()

func draw_palette():
	
	if(palettes == null): return
	
	if(current_palette_index < 0): current_palette_index = palettes.size()-1
	elif (current_palette_index >= palettes.size()): current_palette_index = 0
	
	var pal = palettes[current_palette_index]
	
	label_palette.text = str("Palette ",current_palette_index)
	
	# clear the palette grid
	clear();
	# create and color a square for each palette color
	# and add to grid
	for i in range(0, pal.size()):
		var square = $square.duplicate()
		square.visible = true
		square.self_modulate = pal[i]
		grid.add_child(square)
	

func clear():
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
		
