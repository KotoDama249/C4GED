extends AnimatedSprite2D

@export_range(6, 18) var secret_id: int = 13
@export var target_camera: String = "CAM_01"

var is_spawned_session: bool = false

func _ready() -> void:
	visible = false
	stop()
	if Global.has_signal("camera_closed"):
		Global.camera_closed.connect(_on_camera_closed)

# Called by camconnector right before opening cameras
func force_secret_roll() -> void:
	is_spawned_session = false
	visible = false
	stop()
	
	if Secrets.roll_secret_chance():
		is_spawned_session = true
		Secrets.unlock_secret(secret_id)

func check_camera_visibility(active_cam: String) -> void:
	if not is_spawned_session:
		visible = false
		stop()
		return
		
	if active_cam == target_camera:
		visible = true
		if sprite_frames.has_animation("default"):
			if animation != "default" or not is_playing():
				play("default")
	else:
		visible = false
		stop()

func _on_camera_closed() -> void:
	is_spawned_session = false
	visible = false
	stop()
