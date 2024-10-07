# class for unfolded form of papelito
extends Possess
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()

func _on_unfolded_state_entered() -> void:
	possess()
	%Art.visible = true
	zoom_out()
	%AnimationPlayer.play("kill")

func _on_unfolded_state_exited() -> void:
	un_possess()
	zoom_in()
	%AnimationPlayer.play("RESET")

func zoom_out():
	var tween = get_tree().create_tween()
	tween.tween_property(%PapelitoCam, "zoom", Vector2(0.25, 0.25), 1).set_trans(Tween.TRANS_CUBIC)
	
func zoom_in():
	var tween = get_tree().create_tween()
	tween.tween_property(%PapelitoCam, "zoom", Vector2(0.5, 0.5), 1).set_trans(Tween.TRANS_CUBIC)

func _on_unfolded_transition_pending(initial_delay: float, remaining_delay: float) -> void:
	un_possess()
	%AnimationPlayer.play("folding")
