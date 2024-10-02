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
	state_chart.set_expression_property("on_floor", on_floor)

func possess():
	cast_to_floor()
	visible = true
	process_mode = PROCESS_MODE_INHERIT
	%PapelitoCam.reparent(self)
	%PapelitoCam.transform = Transform2D.IDENTITY

func un_possess():
	if self.transform != Transform2D.IDENTITY:
		get_parent().transform = self.global_transform
	self.transform = Transform2D.IDENTITY
	visible = false
	process_mode = PROCESS_MODE_DISABLED

func did_input(action: StringName) -> bool:
	return state_manager.input_buffer.any(func(entry): return entry.input.is_action(action));

func cast_to_floor(max_distance: float = 500.0) -> bool:
	var collider = get_collider()
	var query = PhysicsShapeQueryParameters2D.new()
	query.set_shape(collider.shape)
	query.set_motion(Vector2.DOWN * max_distance)
	query.set_exclude([self])
	var space_state = get_world_2d().direct_space_state
	var result = space_state.cast_motion(query)
	result.sort()
	self.position += (result[0])*Vector2.DOWN*max_distance	- Vector2.DOWN*(collider.shape as CapsuleShape2D).height
	return true

# Helper Function to Get CollisionShape2D
func get_collider() -> CollisionShape2D:
	for child in get_children():
		if child is CollisionShape2D:
			return child
	return null
