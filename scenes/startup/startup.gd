extends Node2D

const DEBUG = 1
const FORCE_SOURCE_LOAD = 0

@onready var loadstring = $CanvasLayer/ui/loadcontainer/loadstring
@onready var progressbar = $CanvasLayer/ui/loadcontainer/ProgressBar
@onready var load_container = $CanvasLayer/ui/loadcontainer
var thread_ids = []
var update_prefix = ""

func _ready():
	load_container.visible = false
	
func load_resources():
	
	$CanvasLayer/ui/loadcontainer.visible = true
	var load_source = true
	var result = false
	
	if(!FORCE_SOURCE_LOAD):
		loadstring.text = str("Loading data...")
		result = System.load_data("uw1")
		if(result):
			loadstring.text = str("Done.")
			load_source = false
		else: load_source = true
	
	if(load_source):
		$CanvasLayer/ui/loadcontainer.visible = true
		# import source data files
		result = System.load_uw1_resources(Callable(update_progress))
		if (DEBUG): System.print_data_keys(System.cur_data)
		progressbar.visible = false
		loadstring.text = str("Load Successful:", result)
		System.save_data(System.uw1_data)
	if result:
		get_tree().change_scene_to_file("res://scenes/tempmain/tempmain.tscn")

func update_progress(metadata):
	loadstring.text = str(update_prefix, metadata[0])
	progressbar.max_value = metadata[2]
	progressbar.value = metadata[1]

func import_uw1():
	var result
	load_container.visible = true
	update_prefix = "Importing "
	# import source data files
	result = System.import_uw1_resources(Callable(update_progress))
	progressbar.visible = false
	loadstring.text = str("UW1 Import:", result)

func save_raws_file():
	var result = System.save_raws(System.uw1_data)
	loadstring.text = str("UW1 Raws File Save:", result)	

func load_raws_file():
	var result = System.load_raws("uw1")
	loadstring.text = str("Raws File Loaded:",result)	

func generate_resources():
	var result = System.generate_resources_from_raws(System.uw1_data)
	loadstring.text = str("Resources Generated:",result)

func export_resources():
	var result = System.export_resources(System.uw1_data)
	loadstring.text = str("Resources Exported:", result)

func _on_button_import_pressed():
	if(DEBUG): import_uw1()
	else: WorkerThreadPool.add_task(import_uw1)

func _on_button_save_pressed():
	load_container.visible = true
	loadstring.text = str("Saving UW1 Raws File...")
	if(DEBUG): save_raws_file()
	else: WorkerThreadPool.add_task(save_raws_file)

func _on_button_load_pressed():
	load_container.visible = true
	loadstring.text = str("Loading Raws File...")
	if(DEBUG): load_raws_file()
	else: WorkerThreadPool.add_task(load_raws_file)
	
func _on_button_generate_pressed():
	load_container.visible = true
	loadstring.text = str("Generating Resources from Raws...")
	if(DEBUG): generate_resources()
	else: WorkerThreadPool.add_task(generate_resources)

func _on_button_export_pressed():
	load_container.visible = true
	loadstring.text = str("Exporting Resources...");
	if(DEBUG): export_resources()
	else: WorkerThreadPool.add_task(export_resources)

func _on_buttons_temp_main_pressed():
	get_tree().change_scene_to_file("res://scenes/tempmain/tempmain.tscn")

