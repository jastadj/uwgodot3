extends Node2D

@onready var button_images = $ui/VBoxContainer/OptionButton
@onready var slider = $ui/VBoxContainer/slider
@onready var index_label = $ui/VBoxContainer/label_index

var images
var image_index = 0
var sprite_scaler = 4

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = false
	for key in System.cur_data["images"].keys():
		button_images.add_item(key)
	images = System.cur_data["images"][button_images.get_item_text(button_images.selected)]
	slider.max_value = images.size()-1
	
	connect("visibility_changed", _on_visibility_changed)


func _on_visibility_changed():
	if(visible): draw_image()

func _update_scale():
	$Sprite2D.scale = Vector2(sprite_scaler, sprite_scaler)

func draw_image():
	index_label.text = str("Index ", image_index, " / ", images.size()-1)
	$Sprite2D.texture = ImageTexture.create_from_image(images[image_index])
	_update_scale()
	


func _on_slider_value_changed(value):
	image_index = slider.value
	draw_image()


func _on_option_button_item_selected(index):
	images = System.cur_data["images"][button_images.get_item_text(button_images.selected)]
	if (image_index >= images.size()): image_index = images.size()-1
	draw_image()
