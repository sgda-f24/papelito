extends Node2D

@onready var follow_target: Node2D = %Unfolded
@onready var original_position: Vector2
@onready var original_rotation: float

var curve: Curve3D = Curve3D.new()

@export var follow_target_speed = 4.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = position.lerp(follow_target.position , delta * follow_target_speed)

func _on_unfolded_state_entered() -> void:
	pass # Replace with function body.

func _on_unfolded_state_exited() -> void:
	pass # Replace with function body.
	
func generate_random_points_in_box(box_size: Vector3, number_of_points: int) -> Array:
	var random_points = []
	var half_size = box_size / 2.0
	
	for i in range(number_of_points):
		var x = randf_range(-half_size.x, half_size.x)
		var y = randf_range(-half_size.y, half_size.y)
		var z = randf_range(-half_size.z, half_size.z)
		var point = Vector3(x, y, z)
		random_points.append(point)
		
	return random_points
	
func initialize_random_curve(box_size: Vector3, number_of_points: int) -> void:
	curve.clear_points()
	
	curve.add_point(Vector3(original_position.x, original_position.y, 0), )
	
	var random_points = generate_random_points_in_box(box_size, number_of_points)
	for point in random_points:
		curve.add_point(point)
