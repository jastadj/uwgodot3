extends PanelContainer

@onready var optionbtn = $VBoxContainer/OptionButton
@onready var texture = $VBoxContainer/TextureRect
@onready var label_index = $VBoxContainer/label_index
@onready var images = System.cur_data["images"]
@onready var slider = $VBoxContainer/slider

var image_array = 0
var image_index = 0

func _ready():
	
	for key in images.keys():
		optionbtn.add_item(key)
		
	_on_option_button_item_selected(0)
			
func draw_image():
	if(image_index < 0): image_index = images[image_array].size()-1
	elif (image_index >= images[image_array].size()): image_index = 0
	
	label_index.text = str("Index ", image_index)
	slider.max_value = images[image_array].size()-1
	slider.value = image_index
	var newtexture = ImageTexture.new()
	newtexture.set_image(images[image_array][image_index])
	texture.texture = newtexture

func _on_option_button_item_selected(index):
	#image_index = 0
	image_array = optionbtn.get_item_text(index)
	draw_image()

func _on_slider_drag_ended(value_changed):
	image_index = slider.value
	draw_image()

func _on_slider_value_changed(value):
	label_index.text = str("Index ", slider.value)
	image_index = slider.value
	draw_image()
