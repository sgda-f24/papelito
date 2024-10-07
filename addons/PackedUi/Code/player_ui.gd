class_name PlayerUi extends SControl

# PlayerUi is empty by default to allow users to ad their own player UI. It uses the UI.ToggleUi signal to be toggled on and off.

func _process(_delta: float):
	if Input.is_action_just_pressed("pause"):
		UI.TogglePauseGame.emit(true)


func _on_ui_toggle_pause_game(value: bool) -> void:
	if value:
		get_tree().paused = true
		UI.ToggleUi.emit("pause", true, id)
	else:
		get_tree().paused = false


func _on_ui_toggle_ui(_id: String, value: bool, previous: String) -> void:
	if _id == "play":
		Tracks.track_player.play("RESET")
		Tracks.track_player.stop()
		Tracks.track_player.play("level1")
		get_tree().paused = false
