extends Node

const WINDOW_WIDTH = 320
const WINDOW_HEIGHT = 200

var window_scale = 1

func _word_to_vector2i(tword:String):
	var sstring = tword.split(",")
	return Vector2(int(sstring[0]), int(sstring[1]))

func _word_to_vector3i(tword:String):
	var sstring = tword.split(",")
	return Vector3(int(sstring[0]), int(sstring[1]), int(sstring[2]))

func run_script_file(ascript:String):
	var sfile = FileAccess.open(ascript, FileAccess.READ)
	if(!sfile.is_open()):
		printerr("Error opening ", ascript)
		return false
		
	var viewport_game_container = get_tree().current_scene.get_node("CanvasLayer/Control/SubViewportContainer")
	var viewport_game = viewport_game_container.get_node("SubViewport")
	var ui = get_tree().current_scene.get_node("CanvasLayer/Control/ui")
	var vars = {}
	
	# get file lines
	var script_lines = []
	while !sfile.eof_reached():
		script_lines.append(sfile.get_line())
		
	# execute script lines
	for line in script_lines:
		var words = line.split(":")
		
		if(!words.is_empty()):
			if(words[0].begins_with("#")): continue
			elif(vars.has(words[0])):
				pass
			else:
				match words[0]:
					"window":
						match words[1]:
							"scale":
								window_scale = int(words[2])
								get_viewport().get_window().size = Vector2(WINDOW_WIDTH*window_scale, WINDOW_HEIGHT*window_scale)
								get_tree().current_scene.get_node("CanvasLayer").scale = Vector2(window_scale,window_scale)
							"color":
								var color = Color()
								var colorvec = _word_to_vector3i(words[2])
								color.r8 = colorvec[0]
								color.g8 = colorvec[1]
								color.b8 = colorvec[2]
								RenderingServer.set_default_clear_color(color)
					"viewport":
						match words[1]:
							"on":
								viewport_game_container.visible = true
							"off":
								viewport_game_container.visible = false
							"size":
								viewport_game.size = _word_to_vector2i(words[2])
							"position":
								viewport_game_container.position = _word_to_vector2i(words[2])
					"image":
						vars[words[1]] = Sprite2D.new()
						var img = System.cur_data["images"][words[2]][int(words[3])]
						vars[words[1]].centered = false
						vars[words[1]].texture = ImageTexture.create_from_image(img)
						ui.add_child(vars[words[1]])
					
					

				
