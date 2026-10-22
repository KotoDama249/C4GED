extends Camera2D
# I "tooK" this script from Cupcake Framework, too bad!

const SCROLL_SMOOTHING: int = 12 # Lower for smoother scrolling
const SCROLL_SPEED: float = 0.07 # Lower for faster scrolling
const SCROLL_SCREEN_FRACTION: float = 3.0 # Lower for bigger scroll areas

@export var scroll_clamp: int = 650 # Clamps office scrolling on both sides

var scroll_area_left: float
var scroll_area_right: float
var scroll_amount: float = 0
var can_move: bool = true

func _ready() -> void:
	_initialize_scroll_areas()

func _physics_process(delta: float) -> void:
	_handle_move(delta)

func _initialize_scroll_areas() -> void:
	var view_size_x: float = get_viewport().get_visible_rect().size.x
	var scroll_area_size: float = view_size_x / SCROLL_SCREEN_FRACTION
	
	scroll_area_left = scroll_area_size
	scroll_area_right = view_size_x - scroll_area_size

func _handle_move(delta: float) -> void:
	if can_move:
		var mouse_position: Vector2 = get_viewport().get_mouse_position()
		
		# If mouse is on the left side, subtract to pan left
		if mouse_position.x < scroll_area_left:
			scroll_amount -= (scroll_area_left - mouse_position.x) * SCROLL_SPEED
		# If mouse is on the right side, add to pan right
		elif mouse_position.x > scroll_area_right:
			scroll_amount += (mouse_position.x - scroll_area_right) * SCROLL_SPEED
	
	# Clamps the position so the office doesn't leave the frame
	scroll_amount = clamp(scroll_amount, -scroll_clamp, scroll_clamp)
	position.x = lerp(position.x, scroll_amount, SCROLL_SMOOTHING * delta)
	
func reset_to_center() -> void:
	scroll_amount = 0.0 # Or 540 depending on how your coordinates are centered, but usually 0 is the center offset in Godot
	position.x = 0.0
