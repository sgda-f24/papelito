extends Node2D

@onready var follow_target: Node2D = %Unfolded
@onready var original_position: Vector2
@onready var original_rotation: float
@onready var wander_path: Path3D = %Wander
@onready var scissor_model : Node3D = %ScissorsModel
@onready var frustum_box: MeshInstance3D = %Room

var following = true

@export var follow_target_speed = 4.0

func _ready() -> void:
	original_position = Vector2(scissor_model.position.x, scissor_model.position.y)
	original_rotation = scissor_model.rotation.z
	%"ScissorsModel/AnimationPlayer".current_animation = "Scene"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if following:
		var following_path: PathFollow3D = wander_path.get_child(0)
		following_path.global_transform = following_path.transform.interpolate_with(Transform2D.IDENTITY, delta)
		self.position = position.lerp(follow_target.position , delta * follow_target_speed)
	else:
		var following_path: PathFollow3D = wander_path.get_child(0)
		following_path.progress += delta*100

func _on_unfolded_state_entered() -> void:
	following = true
	scissor_model.transform = Transform3D.IDENTITY
	scissor_model.position = Vector3(original_position.x, original_position.y, 0)
	scissor_model.rotate_z(original_rotation)
	%"ScissorsModel/AnimationPlayer".play()

func _on_unfolded_state_exited() -> void:
	following = false
	var following_path: PathFollow3D = wander_path.get_child(0)
	following_path.progress = 0
	scissor_model.transform = Transform3D.IDENTITY
	self.position = Vector2.ZERO
	initialize_random_curve(4)
	scissor_model.reparent(following_path)
	%"ScissorsModel/AnimationPlayer".stop()
	
func generate_random_points_in_box(box_size: Vector3, number_of_points: int) -> Array:
	var random_points = []
	var half_size = box_size / 2.0
	
	for i in range(number_of_points):
		var t = frustum_box.position
		var x = t.x + randf_range(-half_size.x, half_size.x)
		var y = t.y + randf_range(-half_size.y, half_size.y)
		var z = t.z + randf_range(-half_size.z, half_size.z)
		var point = Vector3(x, y, z)
		random_points.append(point)
		
	return random_points
	
func initialize_random_curve(number_of_points: int) -> void:
	var curve = wander_path.curve
	curve.clear_points()
	
	var player_relative_pos = Vector2(0, 100)
	var dir_to_player2d = original_position.direction_to(player_relative_pos)
	var dir_to_player3d = Vector3(dir_to_player2d.x, dir_to_player2d.y, 0)
	var starting_pos = Vector3(original_position.x, original_position.y, 0)
	curve.add_point(starting_pos, dir_to_player3d, -dir_to_player3d)
	
	var box_size = (frustum_box.mesh as BoxMesh).size
	var random_points = generate_random_points_in_box(box_size, number_of_points)
	for point in random_points:
		curve.add_point(point)

	curve.add_point(starting_pos, dir_to_player3d, -dir_to_player3d)
