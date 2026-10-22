extends Area2D

# awesome secret script!

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and Global.is_camera_open == false and event.is_action_pressed("uiClick"):
		if get_parent().name == "Aka Figure":
			var audio_player = $"../Figure Audio"
			
			# Only play if it isn't already playing
			if not audio_player.playing:
				audio_player.play()
