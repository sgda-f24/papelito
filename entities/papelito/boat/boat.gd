extends Possess

@export var water_speed = 400
@export var desired_hover_height: int = 64 # Adjust as needed (in pixels)
@export var spring_constant: float = 500  # Adjust to change spring stiffness
@export var damping: float = 5  # Adjust to change damping effect

func _physics_process(delta):
	super._physics_process(delta)
	
	# Apply gravity when not on the floor
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump
	if did_input("jump") and is_on_floor():
		velocity.y = jump

	# Handle horizontal movement
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	# Apply hover force when over water
	apply_hover_force(delta)

	move_and_slide()

func apply_hover_force(delta):
	if $RayCast2D.is_colliding():
		var collision_point = $RayCast2D.get_collision_point()
		# Offset the collision point upwards by the desired hover height
		var adjusted_collision_point = collision_point - Vector2(0, desired_hover_height)
		# Calculate the current height from the adjusted collision point
		var current_height = global_position.y - adjusted_collision_point.y
		# Displacement is negative current height because we offset the collision point
		var displacement = -current_height
		
		var direction = Input.get_axis("move_left", "move_right")
		if direction and abs(displacement) < 30:
			velocity.x += direction * water_speed


		# Hooke's Law: F = -k * x
		var spring_force = spring_constant * displacement

		# Damping force to reduce oscillation: Fd = -d * v
		var damping_force = -damping * velocity.y

		# Total force
		var total_force = spring_force + damping_force

		# Apply the force to the vertical velocity
		velocity.y += total_force * delta
	else:
		# If not over water, normal gravity applies
		velocity += get_gravity() * delta


func _on_boat_state_entered() -> void:
	possess()

func _on_boat_state_exited() -> void:
	un_possess()
