extends CanvasLayer
class_name FoldTransition

signal folding_finished
signal transition_finished

@onready var tilemap = $TileMapLayer  # Use $ instead of %

@export var transition_time = 1.0  # Ensure it's a float

var fold_done = false
var transition_done = false

func _ready() -> void:
	process_mode = PROCESS_MODE_WHEN_PAUSED  # Ensure processing when paused

func _process(delta: float) -> void:
	if not fold_done:
		var folding_tile = tilemap.get_child(0)
		if folding_tile:
			fold_done = folding_tile.fold_timer.time_left == 0
	else:
		# Transition is done
		# Unpause the game and emit the signal
		process_mode = PROCESS_MODE_ALWAYS
		emit_signal("folding_finished")
	
	if tilemap.get_child_count() == 0:
		get_tree().paused = false
		emit_signal("transition_finished")
		queue_free()
