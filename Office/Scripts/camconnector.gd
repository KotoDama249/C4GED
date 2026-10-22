extends Node2D

@onready var cameras_node = $Cams
@onready var office_camera = $"Base Stuff/Camera2D"
@onready var monitor_area = $"Base Stuff/Central Monitor/Area2D"
@onready var cam_audio = $"Cams/Base Stuff/Blip Audio"

func _ready() -> void:
	if cameras_node:
		cameras_node.visible = false
		
		if cameras_node.has_signal("close_cameras_requested"):
			cameras_node.close_cameras_requested.connect(_on_close_cameras_requested)

	if monitor_area:
		monitor_area.input_event.connect(_on_monitor_button_area_input_event)

func open_cameras() -> void:
	if cameras_node:
		cameras_node.visible = true
		Global.set_camera_open(true)
		
		if cameras_node.has_method("trigger_static_blip"):
			cameras_node.trigger_static_blip()
			$Cams/MapButtons.trigger_static_blip()
			
		if office_camera:
			office_camera.enabled = false
		# print("Cameras opened.")

func _on_close_cameras_requested() -> void:
	if cameras_node:
		cameras_node.visible = false
		Global.set_camera_open(false)
		
		if office_camera:
			office_camera.enabled = true
			if office_camera.has_method("reset_to_center"):
				office_camera.reset_to_center()

func _on_monitor_button_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		open_cameras()
