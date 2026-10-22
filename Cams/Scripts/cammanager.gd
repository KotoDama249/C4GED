extends Control

@export var cam_number_label: Label
@export var cam_room_label: Label

@export var background_sprite: AnimatedSprite2D # bg
@export var characters_node: Control # char node head
@export var static_blip_animation: AnimatedSprite2D # blip anim
@export var camera_switch_audio: AudioStreamPlayer  # blip noise

var room_names = {
	"CAM_01": "elevator",
	"CAM_02": "theta_01",
	"CAM_03": "theta_navy",
	"CAM_04": "phi_01",
	"CAM_05": "phi_02",
	"CAM_06": "varius_01",
	"CAM_07": "varius_olive",
	"CAM_08": "lambda_steel",
	"CAM_09": "lambda_02",
	"CAM_10": "staffRoom_01",
	"CAM_11": "staffRoom_02",
	"CAM_12": "staffRoom_03",
	"CAM_13": "food_court"
}

var room_frames = {
	"CAM_01": 0,
	"CAM_02": 1,
	"CAM_03": 2,
	"CAM_04": 3,
	"CAM_05": 4,
	"CAM_06": 5,
	"CAM_07": 6,
	"CAM_08": 7,
	"CAM_09": 8,
	"CAM_10": 9,
	"CAM_11": 10,
	"CAM_12": 11,
	"CAM_13": 12
}

var current_cam: String = "CAM_01"
var camera_buttons: Array = []

func _ready() -> void:
	_gather_buttons(self)
	switch_camera("CAM_01")
	
	if Global.has_signal("camera_opened"):
		Global.camera_opened.connect(_on_camera_opened)

func _gather_buttons(node: Node) -> void:
	for child in node.get_children():
		if child.has_method("is_camera_button"):
			camera_buttons.append(child)
		_gather_buttons(child)

func _update_all_characters(node: Node, active_cam: String) -> void:
	if node.has_method("update_visibility"):
		node.update_visibility(active_cam)
		
	# Added this line so it catches the in-cam secrets too!
	if node.has_method("check_camera_visibility"):
		node.check_camera_visibility(active_cam)
	
	for child in node.get_children():
		_update_all_characters(child, active_cam)

# Override the call in switch_camera and check_character_transition to scan from the root scene instead of 'self'
func switch_camera(cam_id: String) -> void:
	current_cam = cam_id
	
	if cam_number_label:
		cam_number_label.text = cam_id
	if cam_room_label:
		cam_room_label.text = "ID: " + room_names.get(cam_id, "Unknown Area")
		
	if background_sprite and room_frames.has(cam_id):
		background_sprite.frame = room_frames[cam_id]
		
	trigger_static_blip()
		
	for btn in camera_buttons:
		btn.update_button_state(current_cam)
		
	# Start the search from the root CanvasLayer (parent of Map Buttons) so it catches the Characters node!
	var root_canvas = get_parent() # Or get_tree().current_scene
	if root_canvas:
		_update_all_characters(root_canvas, current_cam)

func check_character_transition(old_room: String, new_room: String, _character_node: Node) -> void:
	var root_canvas = get_parent()
	if root_canvas:
		_update_all_characters(root_canvas, current_cam)
		
	if old_room == current_cam or new_room == current_cam:
		trigger_static_blip()

func trigger_static_blip() -> void:
	if Global.is_camera_open:
		if static_blip_animation:
			static_blip_animation.frame = 0
			static_blip_animation.play()
		if camera_switch_audio:
			camera_switch_audio.play()
			
func _on_camera_opened() -> void:
	if camera_switch_audio:
		camera_switch_audio.stop()
		camera_switch_audio.play()
		
	if static_blip_animation:
		static_blip_animation.frame = 0
		static_blip_animation.play()

	# NEW: force a visibility refresh once all camera_opened
	# listeners (including camsecrets' secret roll) have finished.
	call_deferred("_refresh_current_cam_visibility")

func _refresh_current_cam_visibility() -> void:
	var root_canvas = get_parent()
	if root_canvas:
		_update_all_characters(root_canvas, current_cam)
