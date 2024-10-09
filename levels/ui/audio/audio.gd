extends Node
class_name SimpleAudioManager

# Optionally, you can define export variables to allow editing in the Inspector
@export var master_volume = 1.0
@export var music_volume = 1.0
@export var sfx_volume = 1.0

@onready var audio_player: AnimationPlayer = %AnimationPlayer
@onready var stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _on_ui_button_pressed(id: String, from: String) -> void:
	audio_player.play("button_pressed")

func _on_ui_option_updated(id: String, value: Variant) -> void:
	match id:
		"Master":
			master_volume = value
			# Update the master bus volume
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))
		"Music":
			music_volume = value
			# Update the music bus volume
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))
		"SFX":
			sfx_volume = value
			# Update the SFX bus volume
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))
		_:
			pass
