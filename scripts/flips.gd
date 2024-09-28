extends TileMapLayer

# Number of tiles to modify randomly
@export var num_tiles_to_change = 5
@export var cooldown = 5.0

@onready var cooldown_timer = Timer.new()

func _ready():
	add_child(cooldown_timer)
	cooldown_timer.one_shot = false
	cooldown_timer.wait_time = cooldown
	cooldown_timer.connect("timeout", _on_cooldown_timer_timeout)
	cooldown_timer.start()
	pass

func _on_cooldown_timer_timeout():
	var tiles = get_children()
	print("Flipping tiles...")
	for i in range(num_tiles_to_change):
		var tile = tiles[randi() % tiles.size()] as FoldingTile
		if tile != null and tile.unfold_timer.is_stopped():
			tile.fold()
		
