extends Sprite2D

@export_range(6, 18) var secret_id: int = 6
@export var target_camera: String = "CAM_01"

var is_spawned_session: bool = false

func _ready() -> void:
	visible = false
	if Global.has_signal("camera_opened"):
		Global.camera_opened.connect(_on_camera_opened)
	if Global.has_signal("camera_closed"):
		Global.camera_closed.connect(_on_camera_closed)

func _on_camera_opened() -> void:
	is_spawned_session = false
	visible = false
	
	if Secrets.roll_secret_chance():
		is_spawned_session = true
		Secrets.unlock_secret(secret_id)

func check_camera_visibility(active_cam: String) -> void:
	if not is_spawned_session:
		visible = false
		return
		
	if active_cam == target_camera:
		visible = true
	else:
		visible = false

func _on_camera_closed() -> void:
	is_spawned_session = false
	visible = false
