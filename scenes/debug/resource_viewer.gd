extends Node2D

@onready var image_viewer = $CanvasLayer/ui/resource_viewers/image_viewer
@onready var button_images = $CanvasLayer/ui/VBoxContainer/button_images

@onready var font_viewer = $CanvasLayer/ui/resource_viewers/font_viewer
@onready var button_fonts = $CanvasLayer/ui/VBoxContainer/button_fonts

var current_viewer = null

func _ready():
	button_images.connect("pressed", Callable(select_viewer).bind(image_viewer) )
	button_fonts.connect("pressed", Callable(select_viewer).bind(font_viewer) )
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
	for child in $CanvasLayer/ui/resource_viewers.get_children():
		child.visible = false
