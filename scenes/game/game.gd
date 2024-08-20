extends Node2D

const WINDOW_WIDTH = 320
const WINDOW_HEIGHT = 200
var window_scale = 4

@onready var ui = $CanvasLayer/Control/ui
@onready var viewport_container = $CanvasLayer/Control/SubViewportContainer
@onready var subviewport = $CanvasLayer/Control/SubViewportContainer/SubViewport
@onready var level = $CanvasLayer/Control/SubViewportContainer/SubViewport/level

# UI
var uw1_main_ui = preload("res://ui/uw1/main/main.tscn")
# Render Window
var render_window_rect:Rect2 = Rect2(Vector2(52,19),Vector2(172, 112))

func _ready():
	
	# set the window background color
	RenderingServer.set_default_clear_color(Color.BLACK)
	# update the window size with scale
	update_window()
	# set the window position
	get_viewport().get_window().position = Vector2(50,50)
	
	# adjust the game viewport size & position
	viewport_container.position = render_window_rect.position
	subviewport.size = render_window_rect.size
	
	# add main uw1 ui
	ui.add_child(uw1_main_ui.instantiate())
	
	# load level
	level.load_level(System.cur_data["raws"]["levels"][0])

func _exit_tree():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	
	if event is InputEventKey:
		# toggle fullscreen
		if event.keycode == KEY_F1:
			if event.pressed:
				if viewport_container.position == render_window_rect.position and subviewport.size == Vector2i(render_window_rect.size):
					viewport_container.position = Vector2(0,0)
					subviewport.size = Vector2i(WINDOW_WIDTH, WINDOW_HEIGHT)
					ui.visible = false
				else:
					# adjust the game viewport size & position
					viewport_container.position = render_window_rect.position
					subviewport.size = Vector2i(render_window_rect.size)
					ui.visible = true
		elif event.keycode == KEY_ESCAPE:
			get_tree().change_scene_to_file("res://scenes/startup/startup.tscn")
	
func update_window():
	get_viewport().get_window().size = Vector2(WINDOW_WIDTH*window_scale, WINDOW_HEIGHT*window_scale)
	$CanvasLayer.scale = Vector2(window_scale, window_scale)
