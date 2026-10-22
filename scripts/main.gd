extends Node2D
## Main: starts a run, ramps up difficulty and awards distance points.

const SPEED_RAMP := 4.0         # Pixels/sec added to world speed each second
const MAX_SPEED := 700.0
const CARBON_CREEP := 0.8       # Meter rises slowly on its own (tension!)
const DISTANCE_POINT_EVERY := 0.5   # Seconds per +1 point

var _timer := 0.0


func _ready() -> void:
	GameState.reset()


func _process(delta: float) -> void:
	if not GameState.is_running:
		return

	GameState.game_speed = minf(GameState.game_speed + SPEED_RAMP * delta, MAX_SPEED)
	GameState.add_carbon(CARBON_CREEP * delta)

	_timer += delta
	if _timer >= DISTANCE_POINT_EVERY:
		_timer = 0.0
		GameState.add_score(1)
