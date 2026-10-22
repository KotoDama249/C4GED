extends Control

@export var character_id: String = "marley" 
@export var ai_level: int = 0
@export var character_frames: SpriteFrames
@export var flip_layout: bool = false
@export var linked_to: String = ""

@onready var value_label: Label = $ValueLabel
@onready var arrow_decrease: Area2D = $DecreaseArrow/Area2D
@onready var arrow_increase: Area2D = $IncreaseArrow/Area2D
@onready var portrait: AnimatedSprite2D = $AnimatedSprite2D
@onready var hold_timer: Timer = $HoldTimer

const LINKED_TINT := Color(0.45, 0.45, 0.45, 1.0)

# Tracks what the player is currently holding: -1 for decreasing, 1 for increasing, 0 for nothing
var hold_direction: int = 0

func _ready() -> void:
	add_to_group("ai_selectors")
	
	if character_frames:
		portrait.sprite_frames = character_frames
		
	if flip_layout:
		value_label.position.y -= 282
		$DecreaseArrow.position.y -= 284
		$IncreaseArrow.position.y -= 284
		
	arrow_decrease.input_event.connect(_on_decrease_clicked)
	arrow_increase.input_event.connect(_on_increase_clicked)
	hold_timer.timeout.connect(_on_hold_timeout)
	
	if linked_to != "":
		# Deferred because the leader might not be ready yet
		_sync_from_leader.call_deferred()
	
	update_display()

# --- Linking ---

func _get_leader():
	if linked_to == "":
		return null
	for node in get_tree().get_nodes_in_group("ai_selectors"):
		if node != self and node.character_id == linked_to:
			return node
	return null

func _update_link_visual() -> void:
	var leader = _get_leader()
	var linked: bool = leader != null and leader.ai_level >= 1
	portrait.modulate = LINKED_TINT if linked else Color.WHITE
	value_label.modulate = LINKED_TINT if linked else Color.WHITE
	

func _sync_from_leader() -> void:
	var leader = _get_leader()
	if leader and leader.ai_level >= 1:
		on_leader_changed(leader.ai_level)

func on_leader_changed(level: int) -> void:
	# Follows the leader's level, including 0. Once the leader is at 0,
	# _update_link_visual() sees the link as broken and un-darkens the icon.
	ai_level = level
	update_display()

func _notify_followers() -> void:
	for node in get_tree().get_nodes_in_group("ai_selectors"):
		if node != self and node.linked_to == character_id:
			node.on_leader_changed(ai_level)

# Used for all manual changes. If this is a linked follower, the leader resets to 0.
func _change_level(delta: int) -> void:
	var leader = _get_leader()
	if leader and leader.ai_level >= 1:
		leader.ai_level = 0
		leader.update_display() # also un-darkens every follower
	ai_level = clampi(ai_level + delta, 0, 20)
	update_display()

# --- Input ---

func _on_decrease_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_change_level(-1)
			hold_direction = -1
			hold_timer.start(0.25) # Initial delay
		else:
			_stop_holding()

func _on_increase_clicked(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_change_level(1)
			hold_direction = 1
			hold_timer.start(0.25) # Initial delay
		else:
			_stop_holding()

func _on_hold_timeout() -> void:
	# Speeds up the timer once the rapid scroll kicks in
	hold_timer.wait_time = 0.075
	
	if hold_direction != 0:
		_change_level(hold_direction)

func _input(event: InputEvent) -> void:
	# Safety net: if the mouse is released anywhere on screen, stop holding
	if event is InputEventMouseButton and not event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_stop_holding()

func _stop_holding() -> void:
	hold_direction = 0
	hold_timer.stop()

# --- Display ---

func update_display() -> void:
	value_label.text = "%02d" % ai_level
	
	if ai_level >= 20:
		value_label.add_theme_color_override("font_color", Color(0.753, 0.0, 0.0, 1.0))
		value_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	else:
		value_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		value_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
		
	if ai_level == 0:
		portrait.frame = 0 
	else:
		portrait.frame = 1 

	_update_link_visual()
	_notify_followers()

	if Engine.is_editor_hint(): return
	Characters.set_level(character_id, ai_level)
