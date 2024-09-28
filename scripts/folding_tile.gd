extends Polygon2D
class_name FoldingTile

# Exported variables
@export var fold_duration = 1.0    # Time in seconds for the folding effect to complete
@export var unfold_delay = 3.0     # Time in seconds to wait before automatically unfolding

# Internal state variables
@export var is_folding = false
var is_unfolding = false
var fold_start_time = 0.0

# References to nodes
@onready var unfold_timer = Timer.new()

func _ready():
	# Attach the unfold_timer node to the tile
	add_child(unfold_timer)
	unfold_timer.one_shot = true
	unfold_timer.wait_time = unfold_delay
	unfold_timer.connect("timeout", _on_Timer_timeout)

	# Ensure a unique ShaderMaterial instance
	if self.material and self.material is ShaderMaterial:
		self.material = self.material.duplicate()

	# Set initial folded state if start_folded is true
	set_fold_amount(0.0)
	fold_start_time = Time.get_ticks_msec() / 1000.0  # Capture the start time in seconds
	if is_folding:
		unfold_timer.start()

func set_folding_state(folding: bool):
	is_folding = folding
	fold_start_time = Time.get_ticks_msec() / 1000.0  # Capture the start time in seconds

	if is_folding:
		# Start the unfolding countdown
		unfold_timer.start()
	else:
		unfold_timer.stop()  # Stop the unfold_timer if folding state is set to false

	# Print debug info

func fold():
	set_folding_state(true)

func _process(delta):
	if is_folding:
		# Calculate the elapsed time since folding started

		var elapsed_time = (Time.get_ticks_msec() / 1000.0) - fold_start_time
		var fold_amount = min(1.0, elapsed_time / fold_duration)
		set_fold_amount(fold_amount)

		# Check if fully folded
		if fold_amount >= 1.0:
			is_folding = false
	elif is_unfolding:
		# Calculate the elapsed time since unfolding started

		var elapsed_time = (Time.get_ticks_msec() / 1000.0) - fold_start_time
		var fold_amount = 1.0 - min(1.0, elapsed_time / fold_duration)
		set_fold_amount(fold_amount)

		# Check if fully unfolded
		if fold_amount <= 0.0:
			is_unfolding = false
		

func _on_Timer_timeout():
	unfold_tile()

func unfold_tile():
	# Start the unfolding process
	is_folding = false
	is_unfolding = true
	fold_start_time = Time.get_ticks_msec() / 1000.0  # Capture the start time

func set_fold_amount(amount: float):
	if self and self.material and self.material is ShaderMaterial:
		self.material.set_shader_parameter("fold_amount", clamp(amount, 0.0, 1.0))
