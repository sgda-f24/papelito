# Possess.gd
extends CharacterBody2D
class_name Possess

# Reference to the StateManager
@onready var state_manager: StateManager = %StateManager
@onready var state_chart: StateChart = %StateChart


@export var walk_frequency = 0.01
@export var walk_amplitude = 0.1
@export var speed = 300.0
@export var jump = -500.0

var on_contact = false 

func _ready():
	un_possess()
	state_chart.set_expression_property("on_contact", on_contact)
	%AnimationPlayer.play("RESET")
	
	safe_margin = 0.01
	
func _process(_delta: float) -> void:
	%PapelitoCam.global_rotation = 0
	
	if Input.is_action_just_pressed("goto_checkpoint"):
		if get_parent().checkpoint:
			var transition_scene = load("res://levels/ui/fold_transition.tscn")
			var instance = transition_scene.instantiate()
			add_child(instance)
			# Connect the signal before pausing
			instance.connect("folding_finished", _on_folding_finished)
			get_tree().paused = true
			%AnimationPlayer.play("kill")

func _on_folding_finished():
	update_loc()

func update_loc():
	self.global_position = get_parent().checkpoint.global_position
	cast_to_floor()
	
func _on_player_killed():
	if get_parent().checkpoint:
		var transition_scene = load("res://levels/ui/fold_transition.tscn")
		var instance = transition_scene.instantiate()
		add_child(instance)
		# Connect the signal before pausing
		instance.connect("folding_finished", _on_folding_finished)
		get_tree().paused = true
		cast_to_floor()
		%AnimationPlayer.play("RESET")
		%AnimationPlayer.play("kill")

func _physics_process(delta: float) -> void:
	if get_last_slide_collision():
		on_contact = true
	else:
		on_contact = false
	state_chart.set_expression_property("on_contact", on_contact)
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("move_left", "move_right")

	if direction < 0:
		%Art.scale.x = -abs(%Art.scale.x)
	elif direction > 0.001:
		%Art.scale.x = abs(%Art.scale.x)
	
	# Skew character periodically to simulate walking.
	if velocity:
		%Art.skew = sin(Time.get_ticks_msec()*walk_frequency) * walk_amplitude
		%Art.rotation = -skew
	else:
		lerp(%Art.skew, 0., Time.get_ticks_msec())
		lerp(%Art.rotation, 0., Time.get_ticks_msec())
	
func possess():
	visible = true
	process_mode = PROCESS_MODE_INHERIT
	%PapelitoCam.reparent(self)
	%PapelitoCam.transform = Transform2D.IDENTITY
	cast_to_floor()

func un_possess():
	get_parent().transform = self.global_transform
	self.transform = Transform2D.IDENTITY
	visible = false
	process_mode = PROCESS_MODE_DISABLED

func did_input(action: StringName) -> bool:
	return state_manager.input_buffer.any(func(entry): return entry.input.is_action(action));

func cast_to_floor() -> bool:
	var capsule = get_collider().shape as CapsuleShape2D
	print(%CastToFloor.get_collision_point())
	return true
	
func get_collider() -> CollisionShape2D:
	for child in get_children():
		if child is CollisionShape2D:
			return child
	return null
