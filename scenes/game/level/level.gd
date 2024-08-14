extends Node3D

var tiles = []

func _ready():
	$tiles/floor/Plane.get_active_material(0).set_shader_parameter("img", ImageTexture.create_from_image(System.cur_data["images"]["floor_32"][0]) )
