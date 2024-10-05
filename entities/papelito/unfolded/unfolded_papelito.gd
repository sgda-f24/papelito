# class for unfolded form of papelito
extends Possess

@export var speed = 300.0
@export var jump = -500.0

var distance_travelled = 0
var prev_direction = 1;
var prev_velocity = Vector2()

func _ready() -> void:
	super._ready()
	
	safe_margin = 0.1
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
	

func _on_unfolded_state_exited() -> void:
	un_possess()


func _on_unfolded_transition_pending(initial_delay: float, remaining_delay: float) -> void:
	%Art.visible = false
