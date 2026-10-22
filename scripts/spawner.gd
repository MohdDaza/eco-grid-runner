extends Node2D
## Spawner: creates obstacles and collectables just off the right edge.
## Keep this node at position (0, 0) in the scene.

const GROUND_TOP := 560.0        # Y of the ground's top surface
const SPAWN_MARGIN := 100.0      # How far off-screen items appear
const OBSTACLE_CHANCE := 0.6     # 60% obstacle, 40% collectable

# Edit these lists to add new items. "carbon" is how much it changes the meter.
var obstacle_types: Array[Dictionary] = [
	{"label": "CAR", "dim": Vector2(90, 50), "color": Color(0.35, 0.35, 0.4), "carbon": 15.0},
	{"label": "FACTORY", "dim": Vector2(60, 90), "color": Color(0.45, 0.25, 0.2), "carbon": 20.0},
]
var collectable_types: Array[Dictionary] = [
	{"label": "TREE", "dim": Vector2(40, 40), "color": Color(0.2, 0.7, 0.3), "carbon": -10.0, "points": 10},
	{"label": "RECYCLE", "dim": Vector2(40, 40), "color": Color(0.2, 0.55, 0.9), "carbon": -6.0, "points": 5},
]

var _cooldown := 1.0   # Seconds until the next spawn


func _process(delta: float) -> void:
	if not GameState.is_running:
		return
	_cooldown -= delta
	if _cooldown <= 0.0:
		_spawn()
		# Faster world = slightly shorter gaps, but always jumpable.
		var speed_factor := 1.0 + (GameState.game_speed - GameState.START_SPEED) / 1000.0
		_cooldown = randf_range(1.0, 1.8) / speed_factor


func _spawn() -> void:
	var x := get_viewport_rect().size.x + SPAWN_MARGIN
	var item := ScrollingItem.new()
	var data: Dictionary

	if randf() < OBSTACLE_CHANCE:
		data = obstacle_types.pick_random()
		item.item_type = ScrollingItem.Type.OBSTACLE
		# Obstacles sit on the ground
		item.position = Vector2(x, GROUND_TOP - data["dim"].y / 2.0)
	else:
		data = collectable_types.pick_random()
		item.item_type = ScrollingItem.Type.COLLECTABLE
		# Low = walk into it, high = you must jump for it
		var lift: float = [30.0, 120.0].pick_random()
		item.position = Vector2(x, GROUND_TOP - lift - data["dim"].y / 2.0)
		item.points = data["points"]

	item.label_text = data["label"]
	item.item_size = data["dim"]
	item.color = data["color"]
	item.carbon_change = data["carbon"]
	add_child(item)
