extends Control

const ZOOM_SCALE_MAX = 10

var palettes = null
var aux_palettes = null

@onready var btn_images = $imagescontainer/btn_images
@onready var image_slider = $imagescontainer/index_container/slider_image_index
@onready var pal_slider = $imagescontainer/pal_container/slider_pal_index
@onready var pal_label = $imagescontainer/pal_container/pal_label
@onready var aux_pal_slider = $"imagescontainer/aux-pal_container/slider_aux_pal_index"
@onready var aux_label = $"imagescontainer/aux-pal_container/aux_label"
@onready var index_label = $imagescontainer/lbl_image_index
@onready var image = $imagescontainer/image

var image_scale = 4
var image_set

func _ready():
	
	# build image list
	var images_list = []
	for key in System.cur_data["raws"]["images"]:
		images_list.append(key)
	images_list.sort()
	for imagestr in images_list:
		btn_images.add_item(imagestr)
	
	image_set = btn_images.get_item_text(btn_images.selected)
	_on_btn_images_item_selected(btn_images.selected)

func _input(event):
	if(visible):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				image_scale += 1
				image_scale = clamp(image_scale, 1, ZOOM_SCALE_MAX)
				image.scale = Vector2(image_scale, image_scale)
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				image_scale -= 1
				image_scale = clamp(image_scale, 1, ZOOM_SCALE_MAX)
				image.scale = Vector2(image_scale, image_scale)
				

func _enable_slider(slider:Slider,enabled:bool):
	slider.editable = enabled
	slider.scrollable = enabled
	if(!enabled):slider.value = 0

func _reset_palette_sliders():
	var cur_image = System.cur_data["raws"]["images"][image_set][image_slider.value]
	match(int(cur_image["type"])):
		int(System.IMAGE_FORMAT.FMT_8BIT):
			_enable_slider(aux_pal_slider, false)
			_enable_slider(pal_slider, true)
			pal_slider.value = cur_image["palette"]
		_:
			_enable_slider(aux_pal_slider, true)
			aux_pal_slider.value = cur_image["aux_palette"]
			_enable_slider(pal_slider, false)

func _update_shader_params():
	var shader = image.material	
	
	for i in range(0,16):
		var color = palettes[0][i+48]
		var colorvec = Vector4(color.r,color.g,color.b,color.a)
		shader.set_shader_parameter(str("color",i), colorvec )
	for i in range(16,21):
		var color = palettes[0][i]
		var colorvec = Vector4(color.r,color.g,color.b,color.a)
		shader.set_shader_parameter(str("color",i), colorvec )
	for i in range(21,24):
		var color = palettes[0][i]
		var colorvec = Vector4(color.r,color.g,color.b,color.a)
		shader.set_shader_parameter(str("color",i), colorvec )		
		

func set_palettes(tpalettes, taux_palettes):
	palettes = tpalettes
	aux_palettes = taux_palettes
	pal_slider.max_value = palettes.size()-1
	aux_pal_slider.max_value = aux_palettes.size()-1
	#_update_shader_params()
	draw_image()
	
func draw_image():
	index_label.text = str("Index ", image_slider.value, " / ", image_slider.max_value)
	if(palettes == null or aux_palettes == null): return
	var pal_val = pal_slider.value
	var aux_pal_val = aux_pal_slider.value
	pal_label.text = str("Palette[", pal_val, "]:")
	aux_label.text = str("Aux Palette[", aux_pal_val, "]:")
	var cur_image = System.cur_data["raws"]["images"][image_set][image_slider.value]
	var newimage = System.generate_image_from_image_entry(cur_image, palettes[pal_val], aux_palettes[aux_pal_val])
	image.texture = ImageTexture.create_from_image(newimage)
	image.scale = Vector2(image_scale,image_scale)
	_update_shader_params()
			


func _on_btn_images_item_selected(index):
	image_set = btn_images.get_item_text(btn_images.selected)
	image_slider.max_value = System.cur_data["raws"]["images"][image_set].size()-1
	_reset_palette_sliders()
	draw_image()
	
func _on_slider_image_index_value_changed(value):
	_reset_palette_sliders()
	draw_image()


func _on_slider_pal_index_value_changed(value):
	draw_image()


func _on_slider_aux_pal_index_value_changed(value):
	draw_image()
