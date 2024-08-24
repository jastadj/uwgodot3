extends Control

var blocks = null

# Called when the node enters the scene tree for the first time.
func _ready():
	
	blocks = System.cur_data["raws"]["strings"]["english"]
	
	for block in blocks.keys():
		$VBoxContainer/HBoxContainer/Block.add_item(block)
		
	_on_block_item_selected(0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_block_item_selected(index):
	
	var block_id:String = $VBoxContainer/HBoxContainer/Block.get_item_text(index)
	
	# clear strings
	$VBoxContainer/ItemList.clear()
	
	for i in range(0, blocks[block_id].size()):
		$VBoxContainer/ItemList.add_item(str(i))
		$VBoxContainer/ItemList.add_item(blocks[block_id][i])
		
