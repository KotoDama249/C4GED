extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

# Call this from your Title screen to start the music if it isn't already playing
func play_music() -> void:
	if not audio_player.playing:
		audio_player.play()

# Call this if you ever need to stop it
func stop_music() -> void:
	audio_player.stop()
