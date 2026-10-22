extends Node

var officePan : float
var isActiveLeft: bool = false
var isActiveRight: bool = false

var is_camera_open: bool = false
signal camera_opened
signal camera_closed

func set_camera_open(open: bool) -> void:
	if is_camera_open != open:
		is_camera_open = open
		if open:
			emit_signal("camera_opened")
			#print("Secret Check: Camera Opened!")
		else:
			emit_signal("camera_closed")
			#print("Secret Check: Camera Closed!")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

# func _input(event: InputEvent) -> void:
# 	if event is InputEventKey:
# 		if event.pressed:
# 			if event.keycode == KEY_ESCAPE:
# 				get_tree().quit()

# I wanna make it tied to a pause menu, not just always
