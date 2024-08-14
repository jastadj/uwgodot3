extends Control

func _ready():
	$main.texture = ImageTexture.create_from_image(System.cur_data["images"]["main"][0])
