extends TileMapLayer
# Exported variables for easy customization
@export var tile_id: int = 1                # Tile ID for FoldingTile in TileSet
@export var spawn_interval: float = 1.0      # Time in seconds between spawns
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
	var random_cell = get_random_cell_from_visuals()
	if random_cell == null:
		return
	
	if (active_folding_tiles.any(func(x): x.position == self.map_to_local(random_cell))):
		_on_SpawnTimer_timeout()

	# Place a FoldingTile on the Flips map at the same cell position
	var scenes = packed_scenes.get_source(0)
	var scene = scenes.get_scene_tile_scene(1)
	var folding_tile = scene.instantiate()
	self.add_child(folding_tile)
	folding_tile.position = self.map_to_local(random_cell) as Vector2i

	# Add the FoldingTile to the active_folding_tiles array
	active_folding_tiles.append(folding_tile)

func get_random_cell_from_visuals() -> Vector2i:
	# Get all used cells from the Visuals map
	var used_cells = self.get_used_cells()
	if used_cells.is_empty():
		return Vector2i(1000, 1000)
	
	# Select a random cell
	var random_index = randi() % used_cells.size()
	return used_cells[random_index]

func _process(delta: float) -> void:
	# erase null tiles
	for tile in active_folding_tiles:
		if tile == null:
			active_folding_tiles.erase(tile)
