extends AnimatedSprite2D

@export_range(1, 5) var secret_id: int = 1
var is_active_session: bool = false

func _ready() -> void:
	visible = false
	stop()
	
	if Global.has_signal("camera_opened"):
		Global.camera_opened.connect(_on_camera_opened)
	if Global.has_signal("camera_closed"):
		Global.camera_closed.connect(_on_camera_closed)

func _on_camera_opened() -> void:
	is_active_session = false
	visible = false
	stop()
	
	# Roll 1/250 chance when cameras open
	if Secrets.roll_secret_chance():
		is_active_session = true
		visible = true
		Secrets.unlock_secret(secret_id)
		
		# Play default or first available animation
		var anim_to_play = "default"
		if sprite_frames.get_animation_names().size() > 0:
			anim_to_play = sprite_frames.get_animation_names()[0]
			
		if sprite_frames.has_animation(anim_to_play):
			if animation != anim_to_play or not is_playing():
				play(anim_to_play)

func _on_camera_closed() -> void:
	is_active_session = false
	visible = false
	stop()
