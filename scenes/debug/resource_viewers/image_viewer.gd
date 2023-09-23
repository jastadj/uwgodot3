extends Node2D

@onready var button_images = $ui/VBoxContainer/OptionButton
@onready var slider = $ui/VBoxContainer/slider
@onready var index_label = $ui/VBoxContainer/label_index

var images
var image_index = 0
var sprite_scaler = 2
var sprite_scaler_multiplier = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	var image_list = []
	for key in System.cur_data["images"].keys():
		image_list.append(key)
	image_list.sort()
	for istr in image_list:
		button_images.add_item(istr)
	images = System.cur_data["images"][button_images.get_item_text(button_images.selected)]
	slider.max_value = images.size()-1
	
	connect("visibility_changed", _on_visibility_changed)

func _input(event):
	if (event is InputEventMouseButton):
		if (event.button_index == MOUSE_BUTTON_WHEEL_UP):
			sprite_scaler_multiplier = clamp(sprite_scaler_multiplier+1, 1, 4)
			_update_scale()
		elif (event.button_index == MOUSE_BUTTON_WHEEL_DOWN):
			sprite_scaler_multiplier = clamp(sprite_scaler_multiplier-1, 1, 4)
			_update_scale()

func _on_visibility_changed():
	if(visible): draw_image()

func _update_scale():
	$Sprite2D.scale = Vector2(sprite_scaler*sprite_scaler_multiplier, sprite_scaler*sprite_scaler_multiplier)

func draw_image():
	index_label.text = str("Index ", image_index, " / ", images.size()-1)
	$Sprite2D.texture = ImageTexture.create_from_image(images[image_index])
	_update_scale()
	


func _on_slider_value_changed(value):
	image_index = slider.value
	draw_image()


func _on_option_button_item_selected(_index):
	images = System.cur_data["images"][button_images.get_item_text(button_images.selected)]
	if (image_index >= images.size()): image_index = images.size()-1
	slider.max_value = images.size()-1
	draw_image()
