# FoldingTile.gd
extends Polygon2D
class_name FoldingTile

# Exported variables for easy customization
@export var fold_duration: float = 1.0    # Time in seconds to complete folding
@export var unfold_delay: float = 3.0     # Time in seconds before auto-unfolding
@export var is_folding: bool = true      # Set flag for initiate folding

@onready var material_ref: ShaderMaterial = load("res://shaders/diamond.material")

# References to timers
var fold_timer: Timer
var unfold_timer: Timer

# State tracking
var current_fold_amount: float = 0.0      # Current fold progress (0.0 to 1.0)
var is_unfolding_flag: bool = false       # Indicates if unfolding is in progress

func _ready():
	# Initialize fold_timer
	fold_timer = Timer.new()
	fold_timer.wait_time = fold_duration
	fold_timer.one_shot = true
	fold_timer.connect("timeout", _on_fold_timer_timeout)
	add_child(fold_timer)
	
	# Initialize unfold_timer
	unfold_timer = Timer.new()
	unfold_timer.wait_time = unfold_delay
	unfold_timer.one_shot = true
	unfold_timer.connect("timeout", _on_unfold_timer_timeout)
	add_child(unfold_timer)
	
	# Ensure a unique ShaderMaterial instance
	if self.material and self.material is ShaderMaterial:
		self.material = self.material.duplicate()
	
	# Set initial fold_amount in shader
	set_fold_amount(0.0)
	
	# If is_folding is already true, start folding
	if is_folding:
		start_folding()

func set_folding(state: bool):
	if state and not is_folding:
		start_folding()
	elif not state and is_folding:
		stop_folding()

func start_folding():
	is_folding = true
	is_unfolding_flag = false
	fold_timer.start()

func stop_folding():
	if is_folding:
		is_folding = false
		fold_timer.stop()
		# Optionally, reset fold_amount or perform other actions
		set_fold_amount(0.0)

func _on_fold_timer_timeout():
	# Folding complete, start unfold_timer
	is_folding = false
	is_unfolding_flag = true
	unfold_timer.start()

func _on_unfold_timer_timeout():
	# Start unfolding
	start_unfolding()

func start_unfolding():
	if is_unfolding_flag:
		# Start the unfolding process
		fold_timer.wait_time = fold_duration  # Reuse fold_timer for unfolding
		fold_timer.disconnect("timeout", _on_fold_timer_timeout)  # Prevent duplicate connections
		fold_timer.connect("timeout", _on_unfold_complete)
		fold_timer.start()

func _on_unfold_complete():
	# Unfolding complete, reset fold_timer and destroy the tile
	set_fold_amount(0.0)
	queue_free()

func _process(delta: float):
	if is_folding and fold_timer.time_left > 0:
		# Calculate fold_amount based on remaining time
		current_fold_amount = 1.0 - (fold_timer.time_left / fold_duration)
		set_fold_amount(current_fold_amount)
	elif is_unfolding_flag and fold_timer.time_left > 0:
		# Calculate unfold_amount based on remaining time
		current_fold_amount = (fold_timer.time_left / fold_duration)
		set_fold_amount(current_fold_amount)

func set_fold_amount(amount: float):
	# Clamp the fold_amount between 0.0 and 1.0
	var clamped_amount = clamp(amount, 0.0, 1.0)
	if self.material and self.material is ShaderMaterial:
		self.material.set_shader_parameter("fold_amount", clamped_amount)
