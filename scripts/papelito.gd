extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var distance_travelled = 0
var prev_direction = 1;
var prev_velocity = Vector2()


func _physics_process(delta: float) -> void:

	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Skew character periodically to simulate walking.
	if velocity and is_on_floor():
		if direction != prev_direction or prev_velocity != velocity:
			distance_travelled = 0
			skew = 0
		prev_direction = direction
		prev_velocity = velocity
		distance_travelled += velocity.length() * delta
		skew = sin(distance_travelled*direction * 0.01) * 0.05
	else:
		skew = 0

	move_and_slide()
