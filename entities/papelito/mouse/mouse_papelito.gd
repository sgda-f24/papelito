# class for mouse form of papelito
extends Possess

var up_vector = Vector2.ZERO # local up direction
var right_vector = Vector2.ZERO # local right vector
var gravity_velocity = 0
var jump_velocity = Vector2.ZERO

var last_up_vector = Vector2.ZERO

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	var collision = get_last_slide_collision()
	if collision:
		state_manager.input_buffer.clear
		gravity_velocity = 0
		
		if not is_ghost_collision(up_vector, collision.get_normal()):
			update_frame_of_reference(collision.get_normal())
		
		jump_velocity = Vector2.ZERO
		
		if did_input("jump"):
			jump_velocity += up_vector * -jump
			state_manager.input_buffer.clear
		
	else:
		last_up_vector = Vector2.ZERO

	if direction:
		velocity = (right_vector - up_vector*0.01*direction) * direction * speed 
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		if collision:
			velocity.y = move_toward(velocity.y, 0, speed)
			
	# Add the gravity.
	if not collision:
		gravity_velocity += get_gravity().length() * delta
		velocity.y = gravity_velocity
		
	velocity += jump_velocity
	
	move_and_slide()

func update_frame_of_reference(collision_normal):
	up_vector = collision_normal
	right_vector = -up_vector.orthogonal()
	global_rotation = right_vector.angle()
	
	var was_on_air = last_up_vector.is_equal_approx(Vector2.ZERO)
	var left_wall = up_vector.is_equal_approx(Vector2.RIGHT)
		
	jump_velocity = Vector2.ZERO

func is_ghost_collision(vec, maybe_ghost, epsilon = 0.01):
	return abs(vec.x - maybe_ghost.x) < epsilon and abs(vec.y - maybe_ghost.y) < epsilon

func _on_mouse_state_entered() -> void:
	possess()

func _on_mouse_state_exited() -> void:
	self.rotation = 0
	un_possess()
