static func load_strings_file(filename:String):
	
	var tfile = FileAccess.open(filename, FileAccess.READ)
	var nodes = []
	var root_node = null
	var strings = []
	var node_count:int = 0
	var block_count:int = 0
	var blocks = []
	var decoded_blocks = {}
	var total_string_count:int = 0
	
	if(tfile == null):
		print("Error opening strings file:" + filename)
		return false
	
	# get the node count
	node_count = tfile.get_16()
	#print("nodes count:", node_count)
	
	# read each node (4 bytes each) and add to nodes list
	# char, parent node, left node, right node
	for i in range(0, node_count):
		nodes.append({"c":char(tfile.get_8()), "p":tfile.get_8(), "l":tfile.get_8(), "r":tfile.get_8()})
	
	# get the root node (last node in the list)
	root_node = nodes.back()
	
	# get the number of blocks
	block_count = tfile.get_16()
	#print("block count:", block_count)
	
	# read block ids and offsets
	for i in range(0, block_count):
		# id, offset, string offsets
		blocks.append({"i":tfile.get_16(), "o":tfile.get_32(), "so":[]})
	
	# read block header info
	for block in blocks:
		
		# move to block offset
		tfile.seek(block["o"])
		
		# get the string count
		var string_count:int = tfile.get_16()
		
		# read the string offsets (relative offset from end of block header)
		for i in range(0, string_count):
			block["so"].append(tfile.get_16())
		
		# get the offset of the end of the block
		block["eo"] = tfile.get_position()
	
	# for each block, decode strings using huffman encoding and add
	# to block id string list
	for block in blocks:
		
		# create dictionary entry for block id to store array of strings
		decoded_blocks[str(block["i"])] = []
		
		# decode each string entry in the block
		for string_offset in block["so"]:
			
			# set the current node to the root
			var current_node = root_node
			
			# seek to string offset in file
			tfile.seek(block["eo"] + string_offset)
			
			# get initial byte
			var byte = tfile.get_8()
			# start with most significant bit of the byte
			var bit = 7
			# current string storage
			var word:String = ""
			
			# run the decoding loop until end of word is found ('|' character)
			while true:
						
				# if reached a terminated leaf	
				if current_node["l"] == 0xff and current_node["r"] == 0xff:
					
					# if end of word found, break
					if(current_node["c"] == "|"):
						break
					
					# add the character to the current string
					if(current_node["c"] != "\r") and (current_node["c"] != "\n"):
						word += current_node["c"]
					
					# reset current node to root node
					current_node = root_node
				
				# if bit is high, take the right path			
				if byte & (0x1 << bit):
					current_node = nodes[current_node["r"]]
				# else, take the left path
				else:
					current_node = nodes[current_node["l"]]
				
				# advance the bit
				bit -= 1
				#bit += 1
				
				# if all bits read, reset the bit counter and get new byte
				if bit < 0:
				#if bit > 7:
					bit = 7
					#bit = 0
					byte = tfile.get_8()
			
			# add the word to the decoded block's string list
			decoded_blocks[str(block["i"])].append(word)
			total_string_count += 1
	
	print(total_string_count, " strings loaded to ", decoded_blocks.keys().size(), " blocks.")
	
	# return the dict of decoded blocks
	return decoded_blocks
