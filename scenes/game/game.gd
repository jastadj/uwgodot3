extends Node2D

const WINDOW_WIDTH = 320
const WINDOW_HEIGHT = 200
var window_scale = 4

@onready var ui = $CanvasLayer/Control/ui
@onready var viewport_container = $CanvasLayer/Control/SubViewportContainer
@onready var subviewport = $CanvasLayer/Control/SubViewportContainer/SubViewport

var uw1_main_ui = preload("res://ui/uw1/main/main.tscn")

func _ready():
	
	# set the window background color
	RenderingServer.set_default_clear_color(Color.BLACK)
	# update the window size with scale
	update_window()
	# set the window position
	get_viewport().get_window().position = Vector2(50,50)
	
	# adjust the game viewport size & position
	viewport_container.position = Vector2(52,19)
	subviewport.size = Vector2(172,112)
	
	# add main uw1 ui
	ui.add_child(uw1_main_ui.instantiate())
	
func update_window():
	get_viewport().get_window().size = Vector2(WINDOW_WIDTH*window_scale, WINDOW_HEIGHT*window_scale)
	$CanvasLayer.scale = Vector2(window_scale, window_scale)
