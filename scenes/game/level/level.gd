extends Node3D

var tiles = []

#$tiles/floor/Plane.get_active_material(0).set_shader_parameter("img", ImageTexture.create_from_image(System.cur_data["images"]["floor_32"][0]) )

func _ready():
	pass
	
func load_level(level:Dictionary):
		
	clear_level()
	
	for y in range(0, level["length"]):
		var new_nodey = Node3D.new()
		new_nodey.name = str("y_",y)
		$tiles.add_child(new_nodey)
		for x in range(0, level["width"]):
			var new_nodex = preload("res://level_cell/level_cell.tscn").instantiate()
			new_nodex.name = str("x_",x)
			new_nodey.add_child(new_nodex)
			
	
func clear_level():
	pass
