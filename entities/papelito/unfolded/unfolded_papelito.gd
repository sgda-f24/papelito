# class for unfolded form of papelito
extends Possess
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if did_input("jump") and is_on_floor():
		velocity.y = jump

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	move_and_slide()

func _on_unfolded_state_entered() -> void:
	possess()
	%Art.visible = true
	zoom_out()

func _on_unfolded_state_exited() -> void:
	un_possess()
	zoom_in()

func zoom_out():
	var tween = get_tree().create_tween()
	tween.tween_property(%PapelitoCam, "zoom", Vector2(0.25, 0.25), 1).set_trans(Tween.TRANS_CUBIC)
	
func zoom_in():
	var tween = get_tree().create_tween()
	tween.tween_property(%PapelitoCam, "zoom", Vector2(0.5, 0.5), 1).set_trans(Tween.TRANS_CUBIC)

func _on_unfolded_transition_pending(initial_delay: float, remaining_delay: float) -> void:
	un_possess()
	%AnimationPlayer.play("folding")
