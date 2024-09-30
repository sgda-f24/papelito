extends TileMapLayer
# Exported variables for easy customization             # Tile ID for FoldingTile in TileSet
@export var spawn_interval: float = 0.1      # Time in seconds between spawns
@export var packed_scenes: TileSet

# Internal tracking
@onready var spawn_timer: Timer = Timer.new()

var active_folding_tiles: Array = []

func _ready():
	# Initialize and configure the spawn_timer
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.connect("timeout", _on_SpawnTimer_timeout)
	spawn_timer.start()

	# Seed the random number generator
	randomize()

func _on_SpawnTimer_timeout():
	# Select a random cell position from the Visuals map
	var random_cell = get_random_cell()
	if random_cell == null:
		return
		
	var tile_data = self.get_cell_tile_data(random_cell)
	# Place a FoldingTile on the Folding map at the same cell position
	var scenes = packed_scenes.get_source(0)
	var scene = scenes.get_scene_tile_scene(tile_data.get_custom_data("scene_id"))
	var folding_tile = scene.instantiate()
	self.add_child(folding_tile)
	folding_tile.position = self.map_to_local(random_cell) as Vector2i
	var transformation = get_transformation(tile_data.flip_h, tile_data.flip_v, tile_data.transpose)
	folding_tile.position -= tile_data.texture_origin as Vector2
	folding_tile.rotate(deg_to_rad(transformation.z))
	folding_tile.scale.x *= transformation.x
	folding_tile.scale.y *= transformation.y

	# Add the FoldingTile to the active_folding_tiles array
	active_folding_tiles.append(folding_tile)

func get_random_cell():
	# Get all used cells from the Visuals map
	var used_cells = self.get_used_cells()
	if used_cells.is_empty():
		return null
	
	# Select a random cell
	var random_index = randi() % used_cells.size()
	return used_cells[random_index]

func _process(_delta: float) -> void:
	# erase null tiles
	for tile in active_folding_tiles:
		if tile == null:
			active_folding_tiles.erase(tile)

# Function to map flip and transpose flags to rotation and scaling
func get_transformation(flip_h: bool, flip_v: bool, transpose: bool) -> Vector3:
	var rot = 0
	var scale_x = 1
	var scale_y = 1

	if not flip_h and not flip_v and not transpose:
		# Combination 1: No Transformation
		rot = 0
		scale_x = 1
		scale_y = 1
	elif flip_h and not flip_v and not transpose:
		# Combination 2: Horizontal Flip Only
		rot = 0
		scale_x = -1
		scale_y = 1
	elif not flip_h and flip_v and not transpose:
		# Combination 3: Vertical Flip Only
		rot = 0
		scale_x = 1
		scale_y = -1
	elif not flip_h and not flip_v and transpose:
		# Combination 4: Transpose Only
		rot = 90
		scale_x = 1
		scale_y = -1
	elif flip_h and flip_v and not transpose:
		# Combination 5: Horizontal & Vertical Flips
		rot = 180
		scale_x = 1
		scale_y = 1
	elif flip_h and not flip_v and transpose:
		# Combination 6: Horizontal Flip + Transpose
		rot = 270
		scale_x = 1
		scale_y = -1
	elif not flip_h and flip_v and transpose:
		# Combination 7: Vertical Flip + Transpose
		rot = 90
		scale_x = 1
		scale_y = 1
	elif flip_h and flip_v and transpose:
		# Combination 8: Horizontal, Vertical Flips + Transpose
		rot = 270
		scale_x = -1
		scale_y = -1
	else:
		# Default Case (Should not occur)
		rot = 0
		scale_x = 1
		scale_y = 1

	# Normalize rotation to [0, 360)
	rot = rot % 360

	return Vector3(scale_x, scale_y, rot)
