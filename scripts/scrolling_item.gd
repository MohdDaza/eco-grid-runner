class_name ScrollingItem
extends Area2D
## One obstacle OR collectable. The Spawner creates these in code,
## so there is no scene to build. Visuals are placeholder colored boxes.
## To use real art: replace the ColorRect in _ready() with a Sprite2D.

enum Type { OBSTACLE, COLLECTABLE }

# These are set by the Spawner BEFORE the item enters the scene tree.
var item_type: Type = Type.OBSTACLE
var item_size := Vector2(50, 50)
var color := Color.WHITE
var label_text := ""
var carbon_change := 0.0   # + for obstacles, - for collectables
var points := 0


func _ready() -> void:
	# Collision shape
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = item_size
	shape.shape = rect
	add_child(shape)

	# Placeholder visual
	var visual := ColorRect.new()
	visual.size = item_size
	visual.position = -item_size / 2.0
	visual.color = color
	add_child(visual)

	# Text label above the item. HCI note: meaning is NOT conveyed by color
	# alone, which helps colour-blind players (accessibility).
	var lbl := Label.new()
	lbl.text = label_text
	lbl.position = Vector2(-item_size.x / 2.0, -item_size.y / 2.0 - 24.0)
	add_child(lbl)

	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if not GameState.is_running:
		return
	position.x -= GameState.game_speed * delta   # Scroll left
	if position.x < -200.0:
		queue_free()                             # Off-screen cleanup


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return   # Ignore the ground etc.

	if item_type == Type.OBSTACLE:
		GameState.feedback.emit("%s! +%d CO2" % [label_text, int(carbon_change)], false)
		GameState.add_carbon(carbon_change)
	else:
		GameState.feedback.emit("%s collected! %d CO2, +%d pts" % [label_text, int(carbon_change), points], true)
		GameState.add_score(points)
		GameState.add_carbon(carbon_change)
	queue_free()
