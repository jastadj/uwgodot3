extends Node2D

@onready var image_viewer = $CanvasLayer/ui/HBoxContainer/resource_viewers/image_viewer
@onready var button_images = $CanvasLayer/ui/HBoxContainer/VBoxContainer/button_images

@onready var font_viewer = $CanvasLayer/ui/HBoxContainer/resource_viewers/font_viewer
@onready var button_fonts = $CanvasLayer/ui/HBoxContainer/VBoxContainer/button_fonts

@onready var npc_viewer = $CanvasLayer/ui/HBoxContainer/resource_viewers/npc_viewer
@onready var button_npcs = $CanvasLayer/ui/HBoxContainer/VBoxContainer/button_npcs

@onready var level_viewer = $CanvasLayer/ui/HBoxContainer/resource_viewers/level_viewer
@onready var button_levels = $CanvasLayer/ui/HBoxContainer/VBoxContainer/button_levels

var current_viewer = null

func _ready():
	button_images.connect("pressed", Callable(select_viewer).bind(image_viewer) )
	button_fonts.connect("pressed", Callable(select_viewer).bind(font_viewer) )
	button_npcs.connect("pressed", Callable(select_viewer).bind(npc_viewer))
	button_levels.connect("pressed", Callable(select_viewer).bind(level_viewer))
	
	if(!System.cur_data["raws"].has("palettes")):
		button_images.disabled = true
	if(!System.cur_data["raws"].has("fonts")):
		button_fonts.disabled = true

	
	hide_all_viewers()

func select_viewer(viewer):
	if(current_viewer != null):
		if(current_viewer == viewer and viewer.visible):
			viewer.visible = false
			return
	hide_all_viewers()
	viewer.visible = true
	current_viewer = viewer

func hide_all_viewers():
	for child in $CanvasLayer/ui/HBoxContainer/resource_viewers.get_children():
		child.visible = false

