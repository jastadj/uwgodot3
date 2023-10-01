extends Control

const anim_playback_time_ms = 500

@onready var anims = System.cur_data["raws"]["npcs"]["npc_animations"]
@onready var animation_button = $animation_container/button_animation
@onready var label_anim_index = $animation_container/label_anim_index
@onready var slider_anim_index = $animation_container/slider_anim_index
@onready var label_aux_pal = $animation_container/label_aux_pal
@onready var slider_aux_pal = $animation_container/slider_aux_pal
@onready var slider_frame = $animation_container/slider_frame
@onready var label_frame = $animation_container/label_frame

@onready var npcs = System.cur_data["raws"]["npcs"]["npc"]
@onready var npc_id = $npc_container/HBoxContainer/npc_id
@onready var label_npc_anim_type = $npc_container/label_anim_type

@onready var anim_timer = $anim_timer
@onready var palette = System.generate_palette(System.cur_data["raws"]["palettes"]["main"][0])
var aux_palette = []
var image_scale = 8
var cur_anim_type = null
var valid_anims = []

func _ready():
	for animation in System.cur_data["raws"]["npcs"]["npc_animations"]:
		animation_button.add_item(animation["name"])
	npc_id.max_value = npcs.size()-1
	_on_npc_id_value_changed(npc_id.value)
	anim_timer.time = anim_playback_time_ms
	anim_timer.repeat(true)
	anim_timer.start()
	anim_timer.connect("timeout", Callable(_on_anim_timer_timeout))
	
	
func _update_npc():
	label_npc_anim_type.text = str("Type:",animation_button.get_item_text(animation_button.selected))

func _update_animation_frames():
	# get the target animation frame sequence
	var tanim = cur_anim_type["anims"][valid_anims[slider_anim_index.value]]
	# clear anim frames
	for child in $anim_frames.get_children():
		$anim_frames.remove_child(child)
		child.queue_free()
	# create anim frames
	for frame_index in tanim:
	# generate 
		var newframeimg = Sprite2D.new()
		newframeimg.centered = false
		newframeimg.texture = ImageTexture.create_from_image(
			System.generate_image_from_image_entry(
				cur_anim_type["frames"][frame_index]["image"],
				palette,
				aux_palette
			)
		)
		newframeimg.scale = Vector2(image_scale, image_scale)
		newframeimg.hide()
		var hotspot = Vector2(cur_anim_type["frames"][frame_index]["x"], cur_anim_type["frames"][frame_index]["y"])
		newframeimg.offset = -hotspot
		$anim_frames.add_child(newframeimg)
	# prepare anim playback
	slider_frame.value = 0
	slider_frame.max_value = $anim_frames.get_child_count()-1
	anim_timer.start()

func _update_animation(from_npc:bool = false):
	# if the animation type is changing
	if(cur_anim_type != anims[animation_button.selected]):
		cur_anim_type = anims[animation_button.selected]
		valid_anims = []
		for i in range(0, cur_anim_type["anims"].size()):
			if(cur_anim_type["anims"][i] != null): valid_anims.push_back(i)
		aux_palette = System.generate_aux_palette(cur_anim_type["aux_pals"][slider_aux_pal.value], palette)
		slider_aux_pal.max_value = cur_anim_type["aux_pals"].size()-1
		slider_anim_index.max_value = valid_anims.size()-1
		_update_animation_frames()
	if(from_npc):
		slider_aux_pal.value = npcs[npc_id.value]["aux_pal"]

func _on_anim_timer_timeout():
	_advance_frame()
	

func _advance_frame():
	if($anim_frames.get_child_count()):
		if(slider_frame.value == slider_frame.max_value): slider_frame.value = 0
		else: slider_frame.value += 1
	_show_anim_frame()

func _show_anim_frame():
	if($anim_frames.get_child_count()):
		for child in $anim_frames.get_children():
			child.hide()
		$anim_frames.get_child(slider_frame.value).show()

func _on_npc_id_value_changed(value):
	animation_button.select(npcs[npc_id.value]["anim"])
	_update_animation(true)
	_update_npc()

func _on_button_animation_item_selected(index):
	_update_animation()

func _on_slider_anim_index_value_changed(value):
	_update_animation_frames()

func _on_slider_aux_pal_value_changed(value):
	cur_anim_type = null
	_update_animation()
