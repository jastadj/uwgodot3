extends Node2D

const DEBUG = 1
const FORCE_SOURCE_LOAD = 1

@onready var loadstring = $CanvasLayer/ui/loadcontainer/loadstring
@onready var progressbar = $CanvasLayer/ui/loadcontainer/ProgressBar
var thread_ids = []

func _ready():
	
	if(DEBUG): load_resources()
	else: WorkerThreadPool.add_task(load_resources)
	
func load_resources():
	
	$CanvasLayer/ui/loadcontainer.visible = true
	var load_source = true
	var result = false
	
	if(!FORCE_SOURCE_LOAD):
		load_source = System.load_data("uw1")
	
	if(load_source):
		# import source data files
		result = System.load_uw1_resources(Callable(update_progress))
		if (DEBUG): System.print_data_keys(System.cur_data)
		progressbar.visible = false
		loadstring.text = str("Load Successful:", result)
		System.save_data(System.uw1_data)
	if result:
		get_tree().change_scene_to_file("res://scenes/tempmain/tempmain.tscn")
	
func update_progress(metadata):
	loadstring.text = str("Importing ", metadata[0])
	progressbar.max_value = metadata[2]
	progressbar.value = metadata[1]
