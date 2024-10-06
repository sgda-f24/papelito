extends Possess

@export var glide: float = 0.01
@export var glide_velocity: float = 300

@export var jump_velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity += get_gravity()*glide * delta
		else:
			velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		%AnimationPlayer.play("zero_jump")
		
	velocity += jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
		if not is_on_floor():
			velocity.x += direction * glide_velocity
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	move_and_slide()


func _on_crane_state_entered() -> void:
	possess()


func _on_crane_state_exited() -> void:
	un_possess()
