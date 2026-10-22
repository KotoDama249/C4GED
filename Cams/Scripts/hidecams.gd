extends CanvasLayer

signal close_cameras_requested

@onready var close_button_area = $"Base Stuff/Close Button/Area2D" # Adjust path to match your scene tree!

func _ready() -> void:
	if close_button_area:
		# Connect to mouse_entered to detect when the mouse hovers over the area
		close_button_area.mouse_entered.connect(_on_close_button_area_mouse_entered)

func _on_close_button_area_mouse_entered() -> void:
	# print("Close button hovered over!")
	emit_signal("close_cameras_requested")
	$"../CloseNoise".play()
