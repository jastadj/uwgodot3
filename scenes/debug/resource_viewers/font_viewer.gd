extends Control

@onready var button_fonts = $font_list

var chars = []
var font_scale = 8

func _ready():
	
	var fontnames = []
	if(!System.cur_data["raws"].has("fonts")): return
	for fontname in System.cur_data["raws"]["fonts"].keys():
		fontnames.append(fontname)
	fontnames.sort()
	
	for fontname in fontnames:
		button_fonts.add_item(fontname)
	
	_on_font_list_item_selected(button_fonts.selected)

func _on_font_list_item_selected(index):
	chars = System.generate_font_from_font_entry(System.cur_data["raws"]["fonts"][button_fonts.get_item_text(button_fonts.selected)])
	update_chars()

func _clear_chars():
	for child in $chars.get_children():
		$chars.remove_child(child)
		child.queue_free()	

func create_font_string(tstring):
	var ascii = String(tstring).to_ascii_buffer()
	var xpos = 0
	for char in ascii:
		if (char < chars.size()):
			if(chars[char] != null):
				var newcharsprite = Sprite2D.new()
				newcharsprite.centered = false
				newcharsprite.texture = ImageTexture.create_from_image(chars[char])
				newcharsprite.scale = Vector2(font_scale, font_scale)
				newcharsprite.position.x = xpos
				xpos += newcharsprite.texture.get_width()*font_scale
				$chars.add_child(newcharsprite)

func update_chars():
	_clear_chars()
	var textstring = String($text_entry.text)
	if(!System.cur_data["raws"]["fonts"][button_fonts.get_item_text(button_fonts.selected)]["lowercase"]):
		textstring = textstring.to_upper()
	var fontstring = create_font_string(textstring)
	
func _on_text_entry_text_changed(new_text):
	update_chars()
