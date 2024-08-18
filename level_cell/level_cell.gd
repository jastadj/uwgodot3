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
		
		var tl_height = System.TILE_SIZE
		var tr_height = System.TILE_SIZE
		var br_uv:float = 1.0
		var bl_uv:float = 1.0
		var y_rotation = 0
		var neighbor_cell = null
		
		# north wall
		if i == 0:
			y_rotation = 0
			if north:
				neighbor_cell = north
		# east wall
		elif i == 1:
			y_rotation = -90
			if east:
				neighbor_cell = east
		# south wall
		elif i == 2:
			y_rotation = 180
			if south:
				neighbor_cell = south
		# west wall
		elif i == 3:
			y_rotation = 90
			if west:
				neighbor_cell = west
		
		if neighbor_cell:	
			print("cell height:", height, ", neighbor height:", neighbor_cell.height)
			if neighbor_cell.type == System.TILE_TYPES.SOLID:
				#tl_height = (System.MAX_HEIGHT - height) / 8
				tl_height = floor((float(System.MAX_HEIGHT) - float(height)) / 8.0)
				tr_height = tl_height
			else:
				if (neighbor_cell.height/8) <= (height/8):
					continue
				else:
					tl_height = float((neighbor_cell.height/8) - (height/8)) * (float(System.TILE_SIZE) / 4.0)
					tr_height = tl_height
					
					print("tl/tr heights:", tl_height, ",", tr_height)
		else:
			continue
		
		br_uv = float(tr_height)/float(System.TILE_SIZE)
		bl_uv = float(tl_height)/float(System.TILE_SIZE)
		
		var st = SurfaceTool.new()
		var normal = Vector3(0,0,1)
		st.begin(Mesh.PRIMITIVE_TRIANGLES)

		# TOP-LEFT
		st.set_normal(normal)
		st.set_uv(Vector2(0, 0))
		st.add_vertex(Vector3(-half_size, tl_height, -half_size))

		# TOP-RIGHT
		st.set_normal(normal)
		st.set_uv(Vector2(1, 0))
		st.add_vertex(Vector3(half_size, tr_height, -half_size))
		
		# BOTTOM-RIGHT
		st.set_normal(normal)
		st.set_uv(Vector2(1, br_uv))
		st.add_vertex(Vector3(half_size, 0, -half_size))
		
		#--------------------#
		
		# BOTTOM-RIGHT
		st.set_normal(normal)
		st.set_uv(Vector2(1, br_uv))
		st.add_vertex(Vector3(half_size, 0, -half_size))
		
		# BOTTOM-LEFT
		st.set_normal(normal)
		st.set_uv(Vector2(0, float(tl_height)/float(System.TILE_SIZE)))
		st.add_vertex(Vector3(-half_size, 0, -half_size))
		
		# TOP-LEFT
		st.set_normal(normal)
		st.set_uv(Vector2(0, 0))
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
