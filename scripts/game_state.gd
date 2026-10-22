extends Node
## GameState (AUTOLOAD / global singleton)
## Holds all shared game data and announces changes through signals,
## so the HUD, player and spawner never need direct references to each other.

# --- Signals: the HUD listens to these to give live feedback ---
signal carbon_changed(new_value: float)
signal score_changed(new_score: int)
signal feedback(message: String, is_good: bool)
signal game_over(final_score: int)

# --- Tunable values ---
const MAX_CARBON := 100.0     # Reaching this = game over
const START_CARBON := 30.0
const START_SPEED := 300.0    # World scroll speed in pixels/second

# --- Live data ---
var carbon := START_CARBON
var score := 0
var game_speed := START_SPEED
var is_running := true


func _ready() -> void:
	# Registers keyboard controls in code so you don't have to open the Input Map.
	_ensure_action("jump", [KEY_SPACE, KEY_W, KEY_UP])
	_ensure_action("move_left", [KEY_A, KEY_LEFT])
	_ensure_action("move_right", [KEY_D, KEY_RIGHT])


## Call at the start of every run (Main does this).
func reset() -> void:
	carbon = START_CARBON
	score = 0
	game_speed = START_SPEED
	is_running = true
	carbon_changed.emit(carbon)
	score_changed.emit(score)


## Positive amount = more emissions, negative = cleaner air.
func add_carbon(amount: float) -> void:
	if not is_running:
		return
	carbon = clampf(carbon + amount, 0.0, MAX_CARBON)
	carbon_changed.emit(carbon)
	if carbon >= MAX_CARBON:
		end_game()


func add_score(points: int) -> void:
	if not is_running:
		return
	score += points
	score_changed.emit(score)


func end_game() -> void:
	if not is_running:
		return
	is_running = false
	game_over.emit(score)


func _ensure_action(action: StringName, keys: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k as Key
		InputMap.action_add_event(action, ev)
