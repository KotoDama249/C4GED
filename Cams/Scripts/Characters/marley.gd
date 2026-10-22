extends AnimatedSprite2D

const MARLEY_PATH = [
	"Void", 
	"CAM_02", 
	"CAM_04", 
	"CAM_01", 
	"CAM_06", 
	"CAM_10", 
	"CAM_11", 
	"RightDoor"
]

var path_index: int = 0
@export var ai_level: int = 20 
var move_timer: Timer

# Door state tracking
var is_at_door: bool = false
var door_wait_timer: Timer

func _ready() -> void:
	visible = false
	
	# Regular movement timer
	move_timer = Timer.new()
	add_child(move_timer)
	move_timer.one_shot = true
	move_timer.timeout.connect(_on_ai_tick)
	
	# Dedicated timer for when she is sitting waiting at the right door
	door_wait_timer = Timer.new()
	add_child(door_wait_timer)
	door_wait_timer.one_shot = true
	door_wait_timer.timeout.connect(_on_door_wait_timeout)
	
	_start_next_timer()

func _start_next_timer() -> void:
	if ai_level <= 0 or is_at_door:
		return
	
	var base_time = lerp(12.0, 3.0, clamp(float(ai_level) / 20.0, 0.0, 1.0))
	var randomized_time = base_time + randf_range(-1.0, 2.5)
	
	move_timer.start(max(1.0, randomized_time))

func _on_ai_tick() -> void:
	if ai_level <= 0 or is_at_door:
		return
		
	# Allow the index to reach the final item ("RightDoor")
	if path_index < MARLEY_PATH.size() - 1:
		var old_room = MARLEY_PATH[path_index]
		path_index += 1
		var new_room = MARLEY_PATH[path_index]
		
		if new_room == "RightDoor":
			is_at_door = true
			Characters.marleyAtDoor = true
			visible = false 
			
			var wait_base = lerp(5.0, 2.0, clamp(float(ai_level) / 20.0, 0.0, 1.0))
			door_wait_timer.start(wait_base)
			print("Marley has reached the Right Door and is waiting!")
			return
		else:
			Characters.marleyAtDoor = false
			var manager = _find_map_buttons_manager(get_tree().current_scene)
			if manager:
				manager.check_character_transition(old_room, new_room, self)
				
	_start_next_timer()

# Called when she's finished waiting at the door
func _on_door_wait_timeout() -> void:
	if not is_at_door:
		return
		
	# Check if player's right door is closed (make sure to match your Global variable name for the right door)
	if Global.get("isActiveRight"):
		# Door is closed! Bounce her back to CAM_02 and reset her path
		_bounce_back_to_start()
	else:
		# Door is open! Jumpscare / Attack hits the player
		_trigger_jumpscare()

func _bounce_back_to_start() -> void:
	is_at_door = false
	Characters.marleyAtDoor = false
	path_index = 1 # Points straight to "CAM_02"
	
	# Force refresh camera view if player happens to be looking at CAM_02
	var manager = _find_map_buttons_manager(get_tree().current_scene)
	if manager:
		manager.check_character_transition("RightDoor", "CAM_02", self)
		
	_start_next_timer()

func _trigger_jumpscare() -> void:
	# Put your jumpscare logic or global trigger here!
	print("Marley got past the right door! Jumpscare!")

func update_visibility(active_cam: String) -> void:
	var current_room = MARLEY_PATH[path_index]
	
	if current_room == "Void" or current_room == "RightDoor" or current_room != active_cam or is_at_door:
		visible = false
		if is_playing():
			stop()
		return
		
	visible = true
	if sprite_frames.has_animation(current_room):
		if animation != current_room or not is_playing():
			play(current_room)

func _find_map_buttons_manager(node: Node) -> Node:
	if node.name == "Map Buttons":
		return node
	for child in node.get_children():
		var found = _find_map_buttons_manager(child)
		if found:
			return found
	return null
