# class for mouse form of papelito
extends Possess

@export var walk_length = 0.15
@export var speed = 500.0
@export var jump = 400.0

var up_vector = Vector2.ZERO # local up direction
var right_vector = Vector2.ZERO # local right vector
var gravity_velocity = 0
var jump_velocity = Vector2.ZERO

var last_up_vector = Vector2.ZERO

func _physics_process(delta: float) -> void:
	var collision = get_last_slide_collision()
	if collision:
		gravity_velocity = 0
		
		up_vector = collision.get_normal()
		up_vector = filter_almost_zero(up_vector)
		if not last_up_vector and  up_vector.is_equal_approx(Vector2.RIGHT):
			print("Change Frame of Reference")
			right_vector = -right_vector
			%Art.scale.y = -1
		else:
			%Art.scale.y = 1
			
		last_up_vector = up_vector
		jump_velocity = Vector2.ZERO
		right_vector = -up_vector.orthogonal()
		var angle = right_vector.angle()
		%Art.global_rotation = right_vector.angle()
		
		if did_input("jump"):
			jump_velocity += up_vector*jump
			
		jump_velocity.x = jump_velocity.x*0.95
	else:
		last_up_vector = Vector2.ZERO

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")
	
	if direction < 0:
		%Art.scale.x = -1
	else:
		%Art.scale.x = 1
		
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

func filter_almost_zero(vec, round = 0.01):
	if abs(vec.x) < round:
		vec.x = 0
	if abs(vec.y) < round:
		vec.y = 0
	return vec

func inverse_lerp(a, b, t):
	t = min(max((t-a)/(t-b), 0), 	1)
	return t * t * (3 - 2*t)
	
func _on_mouse_state_entered() -> void:
	possess()

func _on_mouse_state_exited() -> void:
	self.rotation = 0
	un_possess()
