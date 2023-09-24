extends Node2D

const DEBUG = 1

@onready var loadstring = $CanvasLayer/ui/loadcontainer/loadstring
@onready var progressbar = $CanvasLayer/ui/loadcontainer/ProgressBar
var thread_ids = []

func _ready():
	
	if(DEBUG): load_resources()
	else: WorkerThreadPool.add_task(load_resources)
	
func load_resources():
	
	$CanvasLayer/ui/loadcontainer.visible = true
	
	if(!System.load_data("uw1")):
		# import source data files
		var result = System.load_uw1_resources(Callable(update_progress))
		if (DEBUG): System.print_data_keys(System.cur_data)
		progressbar.visible = false
		loadstring.text = str("Success:", result)
		System.save_data(System.uw1_data)
	get_tree().change_scene_to_file("res://scenes/tempmain/tempmain.tscn")
	
func update_progress(metadata):
	loadstring.text = str("Importing ", metadata[0])
	progressbar.max_value = metadata[2]
	progressbar.value = metadata[1]
