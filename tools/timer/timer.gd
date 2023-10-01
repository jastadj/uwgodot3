extends Node

@export var time:int = 0

var _start_time:int = 0
var _running:bool = false
var _is_repeating = false

signal timeout

func _process(delta):
	if (_running):
		if (Time.get_ticks_msec() >= _start_time + time):
			if (_is_repeating):
				_start_time = Time.get_ticks_msec()
			else:
				_running = false
			emit_signal("timeout")

func start():
	_start_time = Time.get_ticks_msec()
	_running = true
	
func stop():
	_running = false
	
func repeat(do_repeat:bool):
	_is_repeating = do_repeat

	
