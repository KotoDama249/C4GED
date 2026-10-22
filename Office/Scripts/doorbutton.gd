extends Area2D

# pick da door
@export var target_door: AnimatedSprite2D 

# can be left/right, not both haha
@export_enum("Left", "Right") var door_side: String = "Left"

# Reference to the button's own animated sprite (assuming the button itself is an AnimatedSprite2D, or has one on it/parent)
@onready var button_sprite: AnimatedSprite2D = get_parent() if get_parent() is AnimatedSprite2D else self as AnimatedSprite2D

var is_on_cooldown: bool = false
@export var action_delay: float = 0.5 

func _ready() -> void:
	input_event.connect(_on_input_event)

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.is_action_pressed("uiClick"):
		if is_on_cooldown or not target_door:
			return 
		
		toggle_door()

func toggle_door() -> void:
	is_on_cooldown = true
	
	if door_side == "Left":
		Global.isActiveLeft = !Global.isActiveLeft
		if Global.isActiveLeft:
			print(target_door.name + " Closing...")
			target_door.play("close")
		else:
			print(target_door.name + " Opening...")
			target_door.play("open")
			
	elif door_side == "Right":
		Global.isActiveRight = !Global.isActiveRight
		if Global.isActiveRight:
			print(target_door.name + " Closing...")
			target_door.play("close")
		else:
			print(target_door.name + " Opening...")
			target_door.play("open")
	
	await get_tree().create_timer(action_delay).timeout
	is_on_cooldown = false
	
# Continuously update the button's visual frame based on door state
func _process(_delta: float) -> void:
	if not button_sprite:
		return
		
	if door_side == "Left":
		# Frame 1 (index 1) if active/closed, Frame 0 if open
		button_sprite.frame = 1 if Global.isActiveLeft else 0
	elif door_side == "Right":
		button_sprite.frame = 1 if Global.isActiveRight else 0
