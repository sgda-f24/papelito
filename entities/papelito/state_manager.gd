# StateManager.gd
extends Node
class_name StateManager

# Input buffer to store movement-related inputs
var input_buffer = []

# Define the time window for the buffer (in miliseconds)
const BUFFER_TIME: int = 100

func _on_root_state_input(event: InputEvent) -> void:
	var current_time = Time.get_ticks_msec()
	self.input_buffer.append({"timestamp": current_time, "input": event})
	
	handle_state_transitions()

func coyote(entry) -> bool:
	var current_time = Time.get_ticks_msec()
	return current_time - entry.timestamp <= BUFFER_TIME

func handle_state_transitions():
	pass

func _process(_delta: float) -> void:
	var current_time = Time.get_ticks_msec()
	self.input_buffer = input_buffer.filter(
		func(entry): return current_time - entry.timestamp <= BUFFER_TIME
	)
