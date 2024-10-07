# StateManager.gd
extends Node
class_name StateManager

# Input buffer to store movement-related inputs
var input_buffer = []

# Define the time window for the buffer (in miliseconds)
const BUFFER_TIME: int = 100
	
func coyote(entry) -> bool:
	var current_time = Time.get_ticks_msec()
	return current_time - entry.timestamp <= BUFFER_TIME

func handle_state_transitions():
	if input_buffer.any(func(entry): return entry.input.is_action("to_unfold")):
		%StateChart.send_event("to_unfold")
	elif input_buffer.any(func(entry): return entry.input.is_action("to_mouse")):
		%StateChart.send_event("to_mouse")
	elif input_buffer.any(func(entry): return entry.input.is_action("to_crane")):
		%StateChart.send_event("to_crane")
	elif input_buffer.any(func(entry): return entry.input.is_action("to_boat")):
		%StateChart.send_event("to_boat")
		

func _input(event):
	var current_time = Time.get_ticks_msec()
	self.input_buffer.append({"timestamp": current_time, "input": event})
	handle_state_transitions()
	
func _process(_delta: float) -> void:
	var current_time = Time.get_ticks_msec()
	self.input_buffer = input_buffer.filter(
		func(entry): return current_time - entry.timestamp <= BUFFER_TIME
	)
	
