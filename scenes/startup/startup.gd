extends Node2D

@onready var loadstring = $CanvasLayer/ui/loadcontainer/loadstring
@onready var progressbar = $CanvasLayer/ui/loadcontainer/ProgressBar

var thread_ids = []

func _ready():
	
	thread_ids.append(WorkerThreadPool.add_task(load_resources))
	
func load_resources():
	var result = System.load_uw1_resources(Callable(test))
	$CanvasLayer/ui/loadcontainer.visible = false
	get_tree().change_scene_to_file("res://scenes/tempmain/tempmain.tscn")
	
func test(metadata):
	loadstring.text = str("Loading ", metadata[0])
	progressbar.max_value = metadata[2]
	progressbar.value = metadata[1]
