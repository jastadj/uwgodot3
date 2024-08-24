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
	_update_buttons();

func _update_buttons():
	
	var has_raws:bool = !System.cur_data["raws"].is_empty()
	var has_resources:bool = !System.cur_data["palettes"].is_empty() or !System.cur_data["images"].is_empty() or !System.cur_data["fonts"].is_empty()
	
	# requires raws
	$CanvasLayer/ui/HBoxContainer/button_generate.disabled = !has_raws
	$CanvasLayer/ui/HBoxContainer/button_save.disabled = !has_raws
	$CanvasLayer/ui/buttons_tools.disabled = !has_raws
	
	# requires resources
	$CanvasLayer/ui/HBoxContainer/button_export.disabled = !has_resources

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
	_update_buttons()

func save_raws_file():
	var result = System.save_raws(System.uw1_data)
	loadstring.text = str("UW1 Raws File Save:", result)
	_update_buttons()

func load_raws_file():
	var result = System.load_raws("uw1")
	loadstring.text = str("Raws File Loaded:",result)
	_update_buttons()

func generate_resources():
	var result = System.generate_resources_from_raws(System.uw1_data)
	loadstring.text = str("Resources Generated:",result)
	_update_buttons()

func export_resources():
	var result = System.export_resources(System.uw1_data)
	loadstring.text = str("Resources Exported:", result)
	_update_buttons()

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

func _on_buttons_tools_pressed():
	get_tree().change_scene_to_file("res://scenes/tempmain/tempmain.tscn")

func _on_button_clear_data_pressed():
	System.delete_imported_data()
	
func _on_button_load_raws_and_play_pressed():
	
	# load raws data
	load_raws_file()
	
	# generate resources
	generate_resources()
	
	# new game
	
	# load game scene
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func _on_button_quit_pressed():
	get_tree().quit()
