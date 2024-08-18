extends Camera3D

@export var mouse_sensitivity:float = 0.0001
@export var camera_speed:float = 0.5

const X_AXIS = Vector3(1, 0, 0)
const Y_AXIS = Vector3(0, 1, 0)

var is_mouse_motion = false
var mouse_speed = Vector2()
var mouse_speed_x = 0
var mouse_speed_y = 0

var allow_move = true
var mouse_look = false

enum LOOK_MODE{NONE, CONTINUOUS, PRESS}
var look_mode = LOOK_MODE.PRESS

@onready var camera_transform = self.get_transform()

@onready var _prev_position = global_position

signal camera_moved

func _ready():
	
	set_physics_process(true)
	set_process_input(true)

func _physics_process(delta):
	
	if !get_window().has_focus():
		return
	elif is_mouse_motion and _is_mouse_looking() :
		mouse_speed = Input.get_last_mouse_velocity()
		is_mouse_motion = false
	else:
		mouse_speed = Vector2(0, 0)
	
	mouse_speed_x += mouse_speed.x * mouse_sensitivity
	mouse_speed_y += mouse_speed.y * mouse_sensitivity
	
	var rot_x = Quaternion(X_AXIS, -mouse_speed_y)
	var rot_y = Quaternion(Y_AXIS, -mouse_speed_x)
	
	if allow_move and get_viewport().gui_get_focus_owner() == null:
		if (Input.is_key_pressed(KEY_W)):
			camera_transform.origin += -self.get_transform().basis.z * camera_speed
		
		if (Input.is_key_pressed(KEY_S)):
			camera_transform.origin += self.get_transform().basis.z * camera_speed
		
		if (Input.is_key_pressed(KEY_A)):
			camera_transform.origin += -self.get_transform().basis.x * camera_speed
		
		if (Input.is_key_pressed(KEY_D)):
			camera_transform.origin += self.get_transform().basis.x * camera_speed
		
		if (Input.is_key_pressed(KEY_Q)):
			camera_transform.origin += -self.get_transform().basis.y * camera_speed
		
		if (Input.is_key_pressed(KEY_E)):
			camera_transform.origin += self.get_transform().basis.y * camera_speed
	
	self.set_transform(camera_transform * Transform3D(rot_y) * Transform3D(rot_x))
	
	if global_position != _prev_position:
		_prev_position = global_position
		emit_signal("camera_moved")


func _input(event):
	
	# if mouse was moving, set the mouse motion flag
	if (event is InputEventMouseMotion):
		is_mouse_motion = true
	elif event is InputEventMouseButton:
		pass

func _is_mouse_looking():
	
	var mouse_looking = false
	
	if look_mode == LOOK_MODE.PRESS:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			mouse_looking = true
	elif look_mode == LOOK_MODE.CONTINUOUS:
		mouse_looking = true
	
	if mouse_looking:
		if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	return mouse_looking
