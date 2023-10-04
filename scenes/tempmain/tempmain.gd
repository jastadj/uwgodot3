extends Node2D

@onready var button_raw_resource_viewer = $CanvasLayer/ui/CenterContainer/VBoxContainer/button_raw_resource_viewer

func _ready():
	button_raw_resource_viewer.connect("pressed", _on_raw_resource_viewer_pressed)
	
func _on_raw_resource_viewer_pressed():
	get_tree().change_scene_to_file("res://scenes/debug/raw_resource_viewer.tscn")
