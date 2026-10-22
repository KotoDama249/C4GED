extends Sprite2D

const MEDUSA_ID: int = 19
var is_triggered_session: bool = false

func _ready() -> void:
	visible = false
	
	# Office check timer (rolls a 1/250 chance every 15 seconds while playing)
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 15.0
	timer.timeout.connect(_on_check_spawn)
	timer.start()

func _on_check_spawn() -> void:
	# Do not spawn if cameras are up or if she already spawned this session
	if Global.is_camera_open or is_triggered_session:
		return
		
	# Roll 1/250 chance
	if Secrets.roll_secret_chance():
		is_triggered_session = true
		visible = true
		Secrets.unlock_secret(MEDUSA_ID)
		print("Medusa (Fate) has appeared in the office!")
