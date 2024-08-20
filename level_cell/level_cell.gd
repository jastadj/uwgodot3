extends Node3D

var west = null
var east = null
var north = null
var south = null

var type:System.TILE_TYPES = System.TILE_TYPES.SOLID
var height:int = 0
var floor_texture:ImageTexture = null
var wall_texture:ImageTexture = null
var ceiling_texture:ImageTexture = null

func  update_walls():
		
	# clear any existing meshes
	for mesh in $meshes/walls.get_children():
		$meshes/walls.remove_child(mesh)
		mesh.queue_free()
	
	# do nothing for solid cells
	if type == System.TILE_TYPES.SOLID:
		return
	
	var wall_meshes:Array = create_wall_meshes()
	for wall_mesh in wall_meshes:
		wall_mesh.mesh.surface_get_material(0).set_shader_parameter("img", wall_texture)
		$meshes/walls.add_child(wall_mesh)

func update_adjacent_walls():
	
	# update walls for adjacent cells
	if north:
		north.update_walls()
	if south:
		south.update_walls()
	if east:
		east.update_walls()
	if west:
		west.update_walls()

func update_floor():
		
	# clear any existing meshes
	for mesh in $meshes/floor.get_children():
		$meshes/floor.remove_child(mesh)
		mesh.queue_free()
	
	# do nothing for solid cells
	if type == System.TILE_TYPES.SOLID:
		return
	
	# create floor mesh
	if type != System.TILE_TYPES.SOLID:
		# create the mesh instance
		var floor_mesh_instance = create_floor_mesh()
		# temp check
		if(floor_mesh_instance):
			floor_mesh_instance.mesh.surface_get_material(0).set_shader_parameter("img", floor_texture )
			$meshes/floor.add_child(floor_mesh_instance)
	
func update_ceiling():
	
	# clear any existing meshes
	for mesh in $meshes/ceiling.get_children():
		$meshes/ceiling.remove_child(mesh)
		mesh.queue_free()
	
	# do nothing for solid cells
	if type == System.TILE_TYPES.SOLID:
		return
		
	# create ceiling mesh
	var ceiling_mesh_instance = create_ceiling_mesh()
	ceiling_mesh_instance.mesh.surface_get_material(0).set_shader_parameter("img", ceiling_texture)
	$meshes/ceiling.add_child(ceiling_mesh_instance)

func set_cell(new_type:System.TILE_TYPES, new_height:int, new_floor_texture:ImageTexture, new_wall_texture:ImageTexture, new_ceil_texture:ImageTexture):
	
	# set the cell type
	type = new_type
	
	# set the cell height
	height = new_height
	
	# set the floor texture
	floor_texture = new_floor_texture
	
	# set the wall texture
	wall_texture = new_wall_texture
	
	# set the ceiling texture
	ceiling_texture = new_ceil_texture
	
	# update floor
	update_floor()
	
	# update walls
	update_walls()
	
	#update ceiling
	update_ceiling()
	
	# update adjacent walls
	update_adjacent_walls()

func create_shader_material() -> ShaderMaterial:
	var shader_mat = ShaderMaterial.new()
	shader_mat.shader = preload("res://shaders/spatialshader_palette_rotation_uw1.gdshader")
	shader_mat.setup_local_to_scene()
	return shader_mat

func create_floor_mesh() -> MeshInstance3D:
	
	var half_size:float = System.TILE_SIZE / 2
	var slope_size:float = System.TILE_SIZE / 4
	var st = SurfaceTool.new()
	var normal = Vector3(0,1,0)
	var tl_height:float = 0
	var tr_height:float = 0
	var bl_height:float = 0
	var br_height:float = 0
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	# adjust slope heights
	if type == System.TILE_TYPES.SLOPE_UP_N:
		tl_height = slope_size
		tr_height = slope_size
	elif type == System.TILE_TYPES.SLOPE_UP_E:
		tr_height = slope_size
		br_height = slope_size
	elif type == System.TILE_TYPES.SLOPE_UP_S:
		bl_height = slope_size
		br_height = slope_size
	elif type == System.TILE_TYPES.SLOPE_UP_W:
		tl_height = slope_size
		bl_height = slope_size
	
	if type == System.TILE_TYPES.OPEN or type == System.TILE_TYPES.DIAG_OPEN_SW \
	or type == System.TILE_TYPES.DIAG_OPEN_NE \
	or (type >= System.TILE_TYPES.SLOPE_UP_N and type <= System.TILE_TYPES.SLOPE_UP_W):
		
		if type != System.TILE_TYPES.DIAG_OPEN_SW:
			
			st.set_normal(normal)
			st.set_uv(Vector2(0, 0))
			st.add_vertex(Vector3(-half_size, tl_height, -half_size))

			st.set_normal(normal)
			st.set_uv(Vector2(1, 0))
			st.add_vertex(Vector3(half_size, tr_height, -half_size))
			
			st.set_normal(normal)
			st.set_uv(Vector2(1, 1))
			st.add_vertex(Vector3(half_size, br_height, half_size))
		
		if type != System.TILE_TYPES.DIAG_OPEN_NE:
			
			st.set_normal(normal)
			st.set_uv(Vector2(1, 1))
			st.add_vertex(Vector3(half_size, br_height, half_size))
			
			st.set_normal(normal)
			st.set_uv(Vector2(0, 1))
			st.add_vertex(Vector3(-half_size, bl_height, half_size))
			
			st.set_normal(normal)
			st.set_uv(Vector2(0, 0))
			st.add_vertex(Vector3(-half_size, tl_height, -half_size))
			
	elif type == System.TILE_TYPES.DIAG_OPEN_SE or type == System.TILE_TYPES.DIAG_OPEN_NW:
		if type != System.TILE_TYPES.DIAG_OPEN_SE:
			
			st.set_normal(normal)
			st.set_uv(Vector2(0, 1))
			st.add_vertex(Vector3(-half_size, bl_height, half_size))

			st.set_normal(normal)
			st.set_uv(Vector2(0, 0))
			st.add_vertex(Vector3(-half_size, tl_height, -half_size))
			
			st.set_normal(normal)
			st.set_uv(Vector2(1, 0))
			st.add_vertex(Vector3(half_size, tr_height, -half_size))
		
		if type != System.TILE_TYPES.DIAG_OPEN_NW:
			
			st.set_normal(normal)
			st.set_uv(Vector2(1, 0))
			st.add_vertex(Vector3(half_size, tr_height, -half_size))
			
			st.set_normal(normal)
			st.set_uv(Vector2(1, 1))
			st.add_vertex(Vector3(half_size, br_height, half_size))
			
			st.set_normal(normal)
			st.set_uv(Vector2(0, 1))
			st.add_vertex(Vector3(-half_size, bl_height, half_size))
	else:
		return null
	
	st.generate_normals()
	st.generate_tangents()
	
	# Commit to a mesh.
	var floor_mesh = st.commit()
	floor_mesh.surface_set_material(0, create_shader_material())
	
	# create the mesh instance
	var floor_mesh_instance = MeshInstance3D.new()
	floor_mesh_instance.name = "floor"
	floor_mesh_instance.mesh = floor_mesh
	floor_mesh_instance.position.y = floor((float(height)/8.0)) * (float(System.TILE_SIZE)/4.0)
	return floor_mesh_instance

func create_wall_meshes() -> Array:
	
	var half_size = System.TILE_SIZE / 2
	var wall_meshes:Array = []
	
	# create all four walls
	for i in range(0, 4):
		
		var tl_height:float = 1.0
		var tr_height:float = 1.0
		var tl_uv:float = 0.0
		var tr_uv:float = 0.0
		var bl_height:float = 0.0
		var br_height:float = 0.0
		var br_uv:float = 1.0
		var bl_uv:float = 1.0
		var y_rotation = 0
		var neighbor_cell = null
		var neighbor_tr_height:float = 0.0
		var neighbor_tl_height:float = 0.0
		
		# select neighbor cell and rotation
		if i == 0:
			neighbor_cell = north
			y_rotation = 0
		elif i == 1:
			neighbor_cell = east
			y_rotation = -90
		elif i == 2:
			neighbor_cell = south
			y_rotation = 180
		elif i == 3:
			neighbor_cell = west
			y_rotation = 90
		
		# must have a neighbor cell to build wall info
		if neighbor_cell == null:
			continue
		
		##############
		# BOTTOM EDGES
		
		# north wall
		if i == 0:
			if type == System.TILE_TYPES.DIAG_OPEN_SE or type == System.TILE_TYPES.DIAG_OPEN_SW:
				continue
			elif type == System.TILE_TYPES.SLOPE_UP_N:
				if height + 8 >= neighbor_cell.height:
					continue
				br_height = 0.25
				bl_height = br_height
			elif type == System.TILE_TYPES.SLOPE_UP_E:
				br_height = 0.25
			elif type == System.TILE_TYPES.SLOPE_UP_W:
				bl_height = 0.25
			
		# east wall
		elif i == 1:
			if type == System.TILE_TYPES.DIAG_OPEN_SW or type == System.TILE_TYPES.DIAG_OPEN_NW:
				continue
			elif type == System.TILE_TYPES.SLOPE_UP_E:
				if height + 8 >= neighbor_cell.height:
					continue
				br_height = 0.25
				bl_height = br_height
			elif type == System.TILE_TYPES.SLOPE_UP_S:
				br_height = 0.25
			elif type == System.TILE_TYPES.SLOPE_UP_N:
				bl_height = 0.25
				
		# south wall
		elif i == 2:
			if type == System.TILE_TYPES.DIAG_OPEN_NE or type == System.TILE_TYPES.DIAG_OPEN_NW:
				continue
			elif type == System.TILE_TYPES.SLOPE_UP_S:
				if height + 8 >= neighbor_cell.height:
					continue
				br_height = 0.25
				bl_height = br_height
			elif type == System.TILE_TYPES.SLOPE_UP_E:
				bl_height = 0.25
			elif type == System.TILE_TYPES.SLOPE_UP_W:
				br_height = 0.25

		# west wall
		elif i == 3:
			if type == System.TILE_TYPES.DIAG_OPEN_SE or type == System.TILE_TYPES.DIAG_OPEN_NE:
				continue
			elif type == System.TILE_TYPES.SLOPE_UP_W:
				if height + 8 >= neighbor_cell.height:
					continue
				br_height = 0.25
				bl_height = br_height
			elif type == System.TILE_TYPES.SLOPE_UP_S:
				bl_height = 0.25
			elif type == System.TILE_TYPES.SLOPE_UP_N:
				br_height = 0.25

				
		###########
		# TOP EDGES
		
		if neighbor_cell.type == System.TILE_TYPES.SOLID:
			# if neighbor is solid, bring the top edges to the max height of the map
			tl_height = float( (System.MAX_HEIGHT - height) / 8) / 4.0
			tr_height = tl_height
		else:
			# if no wall needs to be drawn because the floor is higher than neighbor
			if ((neighbor_cell.height)/8) <= (height/8):
				
				# if height is same as neighbor but neighbor is a slope, dont ignore walls
				if ((neighbor_cell.height)/8) == (height/8) \
				and neighbor_cell.type >= System.TILE_TYPES.SLOPE_UP_N \
				and neighbor_cell.type <= System.TILE_TYPES.SLOPE_UP_W:
					pass
				else:
					continue
					
			neighbor_tl_height = float(neighbor_cell.height/8)/4.0
			neighbor_tr_height = float(neighbor_cell.height/8)/4.0
			
			if i == 0:
				if neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_W:
					neighbor_tl_height += 0.25
				elif neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_E:
					neighbor_tr_height += 0.25
				elif neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_S:
					neighbor_tl_height += 0.25
					neighbor_tr_height += 0.25
			elif i == 1:
				if neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_N:
					neighbor_tl_height += 0.25
				elif neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_S:
					neighbor_tr_height += 0.25
				elif neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_W:
					neighbor_tl_height += 0.25
					neighbor_tr_height += 0.25
			elif i == 2:
				if neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_E:
					neighbor_tl_height += 0.25
				elif neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_W:
					neighbor_tr_height += 0.25
				elif neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_N:
					neighbor_tl_height += 0.25
					neighbor_tr_height += 0.25
			elif i == 3:
				if neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_N:
					neighbor_tr_height += 0.25
				elif neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_S:
					neighbor_tl_height += 0.25
				elif neighbor_cell.type == System.TILE_TYPES.SLOPE_UP_E:
					neighbor_tl_height += 0.25
					neighbor_tr_height += 0.25
			
			# bring the top edge up to meet the neighbor's height				
			tl_height = neighbor_tl_height - float(height/8)/4.0
			tr_height = neighbor_tr_height - float(height/8)/4.0
		
		# convert wall heights to tile size
		tl_height = floor(tl_height * System.TILE_SIZE)
		tr_height = floor(tr_height * System.TILE_SIZE)
		bl_height = floor(bl_height * System.TILE_SIZE)
		br_height = floor(br_height * System.TILE_SIZE)
		
		# calculate texture map coordinates
		
		br_uv = (tr_height - br_height)/System.TILE_SIZE
		bl_uv = (tl_height - bl_height)/System.TILE_SIZE
		
		# bottom edge of wall slope texture coordinates
		if(tr_height > tl_height):
			tl_uv += 0.25
			if(bl_height == br_height):
				bl_uv += 0.25
		elif(tl_height > tr_height):
			tr_uv += 0.25
			if(bl_height == br_height):
				br_uv += 0.25
		
		var st = SurfaceTool.new()
		var normal = Vector3(0,0,1)
		st.begin(Mesh.PRIMITIVE_TRIANGLES)

		# TOP-LEFT
		st.set_normal(normal)
		st.set_uv(Vector2(0, tl_uv))
		st.add_vertex(Vector3(-half_size, tl_height, -half_size))

		# TOP-RIGHT
		st.set_normal(normal)
		st.set_uv(Vector2(1, tr_uv))
		st.add_vertex(Vector3(half_size, tr_height, -half_size))
		
		# BOTTOM-RIGHT
		st.set_normal(normal)
		st.set_uv(Vector2(1, br_uv))
		st.add_vertex(Vector3(half_size, br_height, -half_size))
		
		#--------------------#
		
		# BOTTOM-RIGHT
		st.set_normal(normal)
		st.set_uv(Vector2(1, br_uv))
		st.add_vertex(Vector3(half_size, br_height, -half_size))
		
		# BOTTOM-LEFT
		st.set_normal(normal)
		st.set_uv(Vector2(0, bl_uv))
		st.add_vertex(Vector3(-half_size, bl_height, -half_size))
		
		# TOP-LEFT
		st.set_normal(normal)
		st.set_uv(Vector2(0, tl_uv))
		st.add_vertex(Vector3(-half_size, tl_height, -half_size))
		
		st.generate_normals()
		st.generate_tangents()
		
		# Commit to a mesh.
		var wall_mesh = st.commit()
		wall_mesh.surface_set_material(0, create_shader_material())
		
		# create the mesh instance
		var wall_mesh_instance = MeshInstance3D.new()
		wall_mesh_instance.name = "wall"
		wall_mesh_instance.mesh = wall_mesh
		wall_mesh_instance.position.y = floor((float(height)/8.0)) * (float(System.TILE_SIZE)/4.0)
		
		# rotate mesh
		wall_mesh_instance.rotation_degrees.y = y_rotation
		
		# add to wall mesh list
		wall_meshes.append(wall_mesh_instance)
	
	if type == System.TILE_TYPES.DIAG_OPEN_SW or type == System.TILE_TYPES.DIAG_OPEN_SE or type == System.TILE_TYPES.DIAG_OPEN_NE or type == System.TILE_TYPES.DIAG_OPEN_NW:
		var st = SurfaceTool.new()
		var tl_height = floor((float(System.MAX_HEIGHT) - float(height)) / 8.0)
		var tr_height = tl_height
		var br_uv:float = float(tr_height)/float(System.TILE_SIZE)
		var bl_uv:float = float(tl_height)/float(System.TILE_SIZE)
		var modifier = Vector3(1,1,1)
		
		if type == System.TILE_TYPES.DIAG_OPEN_SE:
			modifier = Vector3(1,1,-1)
		elif type == System.TILE_TYPES.DIAG_OPEN_NW:
			modifier = Vector3(-1, 1, 1)
		elif type == System.TILE_TYPES.DIAG_OPEN_NE:
			modifier = Vector3(-1, 1, -1)
		var normal = Vector3(1,0,1)

		st.begin(Mesh.PRIMITIVE_TRIANGLES)

		# TOP-LEFT
		st.set_normal(normal)
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(-half_size, tl_height, -half_size) * modifier)

		# TOP-RIGHT
		st.set_normal(normal)
		st.set_uv(Vector2(1, 0))
		st.add_vertex(Vector3(half_size, tr_height, half_size) * modifier)
		
		# BOTTOM-RIGHT
		st.set_normal(normal)
		st.set_uv(Vector2(1, br_uv))
		st.add_vertex(Vector3(half_size, 0, half_size) * modifier)
		
		#--------------------#
		
		# BOTTOM-RIGHT
		st.set_normal(normal)
		st.set_uv(Vector2(1, br_uv))
		st.add_vertex(Vector3(half_size, 0, half_size) * modifier)
		
		# BOTTOM-LEFT
		st.set_normal(normal)
		st.set_uv(Vector2(0, bl_uv))
		st.add_vertex(Vector3(-half_size, 0, -half_size) * modifier)
		
		# TOP-LEFT
		st.set_normal(normal)
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(-half_size, tl_height, -half_size) * modifier)
		
		st.generate_normals()
		st.generate_tangents()
		
		# Commit to a mesh.
		var wall_mesh = st.commit()
		wall_mesh.surface_set_material(0, create_shader_material())
		
		# create the mesh instance
		var wall_mesh_instance = MeshInstance3D.new()
		wall_mesh_instance.name = "wall"
		wall_mesh_instance.mesh = wall_mesh
		wall_mesh_instance.position.y = floor((float(height)/8.0)) * (float(System.TILE_SIZE)/4.0)

		# add to wall mesh list
		wall_meshes.append(wall_mesh_instance)
	
	return wall_meshes

func create_ceiling_mesh() -> MeshInstance3D:
	
	var half_size = System.TILE_SIZE / 2
	var st = SurfaceTool.new()
	var normal = Vector3(0,1,0)
	
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	st.set_normal(normal)
	st.set_uv(Vector2(0, 0))
	st.add_vertex(Vector3(-half_size, 0, -half_size))

	st.set_normal(normal)
	st.set_uv(Vector2(1, 0))
	st.add_vertex(Vector3(half_size, 0, -half_size))
	
	st.set_normal(normal)
	st.set_uv(Vector2(1, 1))
	st.add_vertex(Vector3(half_size, 0, half_size))
	
	
	st.set_normal(normal)
	st.set_uv(Vector2(1, 1))
	st.add_vertex(Vector3(half_size, 0, half_size))
	
	st.set_normal(normal)
	st.set_uv(Vector2(0, 1))
	st.add_vertex(Vector3(-half_size, 0, half_size))
	
	st.set_normal(normal)
	st.set_uv(Vector2(0, 0))
	st.add_vertex(Vector3(-half_size, 0, -half_size))
	
	st.generate_normals()
	st.generate_tangents()
	
	# Commit to a mesh.
	var ceil_mesh = st.commit()
	ceil_mesh.surface_set_material(0, create_shader_material())
	
	# create the mesh instance
	var ceil_mesh_instance = MeshInstance3D.new()
	ceil_mesh_instance.name = "ceiling"
	ceil_mesh_instance.mesh = ceil_mesh
	ceil_mesh_instance.position.y = floor((float(System.MAX_HEIGHT)/8.0)) * (float(System.TILE_SIZE)/4.0)
	ceil_mesh_instance.rotation_degrees.x = 180
	return ceil_mesh_instance
