extends Node2D

@onready var abyssmal = load("res://system/abyssmal_script/abyssmal_script.gd").new()
var scriptfile = "user://data/uw1/script.abyssmal"

func _ready():
		
	add_child(abyssmal)
	abyssmal.run_script_file(scriptfile)
