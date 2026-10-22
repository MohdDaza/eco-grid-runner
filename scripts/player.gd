extends CharacterBody2D
## Player: moves left/right and jumps. Attach to a CharacterBody2D.

const GRAVITY := 1800.0
const JUMP_VELOCITY := -700.0   # Negative = up in Godot 2D
const MOVE_SPEED := 300.0
const MIN_X := 60.0             # Keep the player on screen
const MAX_X := 1100.0


func _ready() -> void:
	# Collectables/obstacles check this group to know it's the player.
	add_to_group("player")


func _physics_process(delta: float) -> void:
	if not GameState.is_running:
		return

	# Gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# Jump (only when standing on the ground)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement (-1 left, 0 none, +1 right)
	var direction := Input.get_axis("move_left", "move_right")
	velocity.x = direction * MOVE_SPEED

	move_and_slide()
	position.x = clampf(position.x, MIN_X, MAX_X)
