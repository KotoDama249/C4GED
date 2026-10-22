extends AnimatedSprite2D

const KACEY_ROOM = "CAM_08" # lambda_steel

@export var ai_level: int = 20 # Testing high AI

var move_timer: Timer
var gainer_counter: int = 0
var current_stage: int = 1
var is_active: bool = true

# Camera watch tracking variables
var watch_timer: float = 0.0
const REQUIRED_WATCH_TIME: float = 2.0 # Time needed staring at CAM_08 to reset her

# Tracking state for her door rush
var is_rushing: bool = false
var door_wait_timer: Timer

func _ready() -> void:
	visible = false
	
	move_timer = Timer.new()
	add_child(move_timer)
	move_timer.one_shot = true
	move_timer.timeout.connect(_on_timer_timeout)
	
	door_wait_timer = Timer.new()
	add_child(door_wait_timer)
	door_wait_timer.one_shot = true
	door_wait_timer.timeout.connect(_on_door_wait_timeout)
	
	_start_next_timer()

func _start_next_timer() -> void:
	if not is_active or ai_level <= 0 or is_rushing or Characters.kaceyAtDoor:
		return
	
	var base_time = lerp(0.8, 0.2, clamp(float(ai_level) / 20.0, 0.0, 1.0))
	var randomized_time = max(0.05, base_time + randf_range(-0.05, 0.1))
	move_timer.start(randomized_time)

func _on_timer_timeout() -> void:
	if is_rushing:
		_arrive_at_door()
	else:
		_on_ai_tick()

func _on_ai_tick() -> void:
	if not is_active or current_stage >= 6 or is_rushing:
		return
		
	var manager = _find_map_buttons_manager()
	
	# Only pause/stall gains if the cameras are ACTUALLY open AND player is looking at CAM_08
	if Global.is_camera_open and manager and manager.get("current_cam") == KACEY_ROOM:
		_start_next_timer()
		return
		
	gainer_counter += 1
	
	if gainer_counter >= 35:
		gainer_counter = 0
		current_stage += 1
		Characters.kaceyStage = current_stage
		
		if manager:
			manager.check_character_transition(KACEY_ROOM, KACEY_ROOM, self)
			
		if current_stage >= 6:
			_start_rush_travel()
			return

	_start_next_timer()

func _start_rush_travel() -> void:
	is_rushing = true
	visible = false
	
	var rush_time = lerp(4.0, 1.5, clamp(float(ai_level) / 20.0, 0.0, 1.0))
	move_timer.start(rush_time)

func _arrive_at_door() -> void:
	is_rushing = false
	Characters.kaceyAtDoor = true
	
	var door_wait_base = lerp(4.0, 1.5, clamp(float(ai_level) / 20.0, 0.0, 1.0))
	door_wait_timer.start(door_wait_base)

func _on_door_wait_timeout() -> void:
	if not Characters.kaceyAtDoor:
		return
		
	var door_is_closed = Global.get("isActiveLeft")
	
	if door_is_closed and not Characters.kaceyBlocked:
		Characters.kaceyBlocked = true
		_bounce_back_to_room()
	else:
		_trigger_jumpscare()

func _bounce_back_to_room() -> void:
	Characters.kaceyAtDoor = false
	current_stage = 1
	gainer_counter = 0
	watch_timer = 0.0
	Characters.kaceyStage = 1
	
	var manager = _find_map_buttons_manager()
	if manager:
		manager.check_character_transition(KACEY_ROOM, KACEY_ROOM, self)
		if manager.has_method("trigger_static_blip"):
			manager.trigger_static_blip()
			
	_start_next_timer()

func _trigger_jumpscare() -> void:
	print("Kacey got past the left door! Jumpscare!")

func update_visibility(active_cam: String) -> void:
	if current_stage >= 6 or is_rushing or Characters.kaceyAtDoor:
		visible = false
		if is_playing():
			stop()
		return
		
	if active_cam == KACEY_ROOM:
		visible = true
		var anim_name = "Stage " + str(current_stage)
		if sprite_frames.has_animation(anim_name):
			if animation != anim_name or not is_playing():
				play(anim_name)
		else:
			print("Warning: Animation '", anim_name, "' not found in Kacey's SpriteFrames!")
	else:
		visible = false

# Continuous check for whether the player is staring at her on the monitor
func _process(delta: float) -> void:
	if current_stage <= 1 or is_rushing or Characters.kaceyAtDoor:
		return
	
	# Only track/reset if the cameras are actually open!
	if not Global.is_camera_open:
		# Optionally decay watch timer when monitor is down, or just return
		watch_timer = max(0.0, watch_timer - (delta * 0.5))
		return
	
	var manager = _find_map_buttons_manager()
	if manager:
		var active_cam = manager.get("current_cam")
		
		if active_cam == KACEY_ROOM:
			watch_timer += delta
			if watch_timer >= REQUIRED_WATCH_TIME:
				_reset_kacey()
		else:
			watch_timer = max(0.0, watch_timer - (delta * 0.5))

func _reset_kacey() -> void:
	current_stage = 1
	gainer_counter = 0
	watch_timer = 0.0
	Characters.kaceyStage = 1
	Characters.kaceyBlocked = false
	
	var manager = _find_map_buttons_manager()
	if manager:
		manager.check_character_transition(KACEY_ROOM, KACEY_ROOM, self)
		if manager.has_method("trigger_static_blip"):
			manager.trigger_static_blip()
			
	_start_next_timer()

func _find_map_buttons_manager() -> Node:
	var current_scene = get_tree().current_scene
	if current_scene:
		var found = current_scene.find_child("Map Buttons", true, false)
		if found:
			return found
	return null
