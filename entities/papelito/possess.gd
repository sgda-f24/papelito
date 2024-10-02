# Possess.gd
extends CharacterBody2D
class_name Possess

# Reference to the StateManager
@onready var state_manager: StateManager = %StateManager
@onready var state_chart: StateChart = %StateChart

var on_floor = true

func _ready():
	un_possess()
	state_chart.set_expression_property("on_floor", on_floor)

func _process(_delta: float) -> void:
	%PapelitoCam.global_rotation = 0

func _physics_process(delta: float) -> void:
	on_floor = is_on_floor()
	print(on_floor)
	state_chart.set_expression_property("on_floor", on_floor)

func possess():
	visible = true
	process_mode = PROCESS_MODE_INHERIT
	%PapelitoCam.reparent(self)
	%PapelitoCam.transform = Transform2D.IDENTITY
	shapecast_to_floor(self.get_collision_shape())

func un_possess():
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	get_parent().transform = self.transform

func did_input(action: StringName) -> bool:
	return state_manager.input_buffer.any(func(entry): return entry.input.is_action(action));

func shapecast_to_floor(collision_shape: CollisionShape2D, max_distance: float = 1000.0) -> bool:
	if collision_shape == null:
		push_error("shapecast_to_floor called with null CollisionShape2D")
		return false
	
	var shape = collision_shape.shape
	var transform = collision_shape.global_transform
	var origin = transform.origin
	var direction = Vector2.DOWN
	var space_state = get_world_2d().direct_space_state

	# Define the end point for the shapecast
	var cast_to = origin + direction * max_distance

	# Prepare the shapecast parameters
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(shape)
	query.set_transform(collision_shape.global_transform)
	query.set_motion(Vector2.DOWN * max_distance)
	query.set_exclude([self])

	# Perform the shapecast
	var result = space_state.intersect_shape(query)

	if result:
		# Find the closest collision point
		var closest = null
		var min_distance = max_distance
		for collision in result:
			var distance = (collision.collider.position - origin).length()
			if distance < min_distance:
				min_distance = distance
				closest = collision

		if closest:
			# Snap the character to the floor based on the collision point
			# Adjust snapping based on shape type and size
			var snap_offset = get_snap_offset(collision_shape)
			var snap_position = closest.collider.position - snap_offset
			global_position = snap_position
			on_floor = true
			state_chart.set_expression_property("on_floor", on_floor)
			return true

	# If no collision detected
	on_floor = false
	state_chart.set_expression_property("on_floor", on_floor)
	return false

# Helper Function to Get CollisionShape2D
func get_collision_shape() -> CollisionShape2D:
	for child in get_children():
		if child is CollisionShape2D:
			return child
	return null

# Helper Function to Calculate Snap Offset Based on Shape Type
func get_snap_offset(collision_shape: CollisionShape2D) -> Vector2:
	var shape = collision_shape.shape
	if shape is RectangleShape2D:
		# Assuming rectangle is axis-aligned
		return Vector2(0, shape.extents.y)
	elif shape is CircleShape2D:
		return Vector2(0, shape.radius)
	elif shape is CapsuleShape2D:
		return Vector2(0, shape.radius)
	# Add more shape types as needed
	else:
		return Vector2.ZERO
