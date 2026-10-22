extends Area2D

@export var cam_id: String = "CAM_01" 
@onready var animated_sprite: AnimatedSprite2D = get_parent()

func _ready() -> void:
	input_event.connect(_on_input_event)

func is_camera_button() -> bool:
	return true

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var manager = _find_map_buttons_manager(get_tree().current_scene)
		if manager and manager.has_method("switch_camera"):
			manager.switch_camera(cam_id)

func _find_map_buttons_manager(node: Node) -> Node:
	if node.name == "Map Buttons":
		return node
	for child in node.get_children():
		var found = _find_map_buttons_manager(child)
		if found:
			return found
	return null

func update_button_state(active_cam: String) -> void:
	if animated_sprite:
		if cam_id == active_cam:
			animated_sprite.play("flash")
		else:
			animated_sprite.play("off")
