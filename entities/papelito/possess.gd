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
	visible = true
	process_mode = PROCESS_MODE_INHERIT
	%PapelitoCam.reparent(self)
	%PapelitoCam.transform = Transform2D.IDENTITY

func un_possess():
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	get_parent().transform = self.transform

func did_input(action: StringName) -> bool:
	return state_manager.input_buffer.any(func(entry): return entry.input.is_action(action));
