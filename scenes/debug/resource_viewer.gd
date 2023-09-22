extends Node2D

@onready var palette_viewer = $resource_viewers/palette_viewer
@onready var aux_palette_viewer = $resource_viewers/aux_palette_viewer
@onready var image_viewer = $resource_viewers/image_viewer

@onready var button_palettes = $CanvasLayer/ui/VBoxContainer/button_palettes
@onready var button_aux_palettes = $CanvasLayer/ui/VBoxContainer/button_aux_palettes
@onready var button_images = $CanvasLayer/ui/VBoxContainer/button_images

var current_viewer = null

func _ready():
	
	button_palettes.connect("pressed", Callable(select_viewer).bind(palette_viewer) )
	button_aux_palettes.connect("pressed", Callable(select_viewer).bind(aux_palette_viewer))
	button_images.connect("pressed", Callable(select_viewer).bind(image_viewer) )
	

func _input(event):
	
	if(event.is_action_pressed("ui_left")):
		pass

func select_viewer(viewer):
	hide_all_viewers()
	viewer.visible = true
	current_viewer = viewer

func hide_all_viewers():
	for child in $resource_viewers.get_children():
		child.visible = false
