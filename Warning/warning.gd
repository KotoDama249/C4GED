extends Sprite2D

var canSkip : bool = true

func _ready() -> void:
	$"../Timer".connect("timeout", timerTimeout)
	$"../AnimationPlayer".connect("animation_finished", animDone)

func timerTimeout() -> void:
	canSkip = false
	$"../AnimationPlayer".play("fade_out")
	
func animDone(animName : StringName) -> void:
	if animName == "fade_out":
		get_tree().change_scene_to_file("res://Scenes/title.tscn")

func _input(event: InputEvent) -> void:
	if canSkip and event.is_action_pressed("confirm"):
		canSkip = false
		$"../AnimationPlayer".play("fade_out")
