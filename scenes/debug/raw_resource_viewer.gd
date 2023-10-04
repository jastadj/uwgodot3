extends Node2D

# buttons
@onready var button_container = $CanvasLayer/ui/button_container
@onready var button_images = button_container.get_node("button_images")
@onready var button_fonts = button_container.get_node("button_fonts")
@onready var button_npcs = button_container.get_node("button_npcs")
@onready var button_levels = button_container.get_node("button_levels")

# viewers
@onready var viewer_container = $CanvasLayer/ui/resource_viewers
@onready var image_viewer = viewer_container.get_node("image_viewer")
@onready var font_viewer = viewer_container.get_node("font_viewer")
@onready var npc_viewer = viewer_container.get_node("npc_viewer")
@onready var level_viewer = viewer_container.get_node("level_viewer")


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
	for child in viewer_container.get_children():
		child.visible = false

