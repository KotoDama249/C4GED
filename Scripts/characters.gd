extends Node

# Marley's data
var marleyCurrentRoom: String = "Void"
var marleyAtDoor: bool = false

# Kacey's data
var kaceyCurrentRoom: String = "CAM_08"
var kaceyStage: int = 1
var kaceyAtDoor: bool = false
var kaceyBlocked: bool = false # Tracks if she has already been blocked by the door once

# Custom Night AI levels, keyed by character_id (e.g. "marley", "kacey")
var ai_levels: Dictionary = {}

func set_level(character_id: String, level: int) -> void:
	ai_levels[character_id] = level

func get_level(character_id: String) -> int:
	return ai_levels.get(character_id, 0)
