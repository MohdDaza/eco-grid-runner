extends CanvasLayer
## HUD: builds the UI in code and reacts to GameState signals.
##
## HCI principles used:
##  - VISIBILITY: score + carbon meter always on screen, with a text status
##    (LOW / RISING / CRITICAL) so meaning isn't carried by colour alone.
##  - FEEDBACK: every pickup/hit shows a message and a quick screen flash.
##  - SYSTEM STATUS: meter colour changes green -> amber -> red.

var score_label: Label
var carbon_label: Label
var carbon_bar: ProgressBar
var feedback_label: Label
var flash: ColorRect
var game_over_box: VBoxContainer
var final_label: Label

var _fill_style := StyleBoxFlat.new()
var _feedback_tween: Tween


func _ready() -> void:
	_build_ui()
	GameState.carbon_changed.connect(_on_carbon_changed)
	GameState.score_changed.connect(_on_score_changed)
	GameState.feedback.connect(_on_feedback)
	GameState.game_over.connect(_on_game_over)
	_on_carbon_changed(GameState.carbon)
	_on_score_changed(GameState.score)


func _build_ui() -> void:
	var vp := get_viewport().get_visible_rect().size

	# Full-screen flash overlay (added first so it's behind the text)
	flash = ColorRect.new()
	flash.size = vp
	flash.color = Color(0, 0, 0, 0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(flash)

	# Eco score
	score_label = Label.new()
	score_label.position = Vector2(24, 16)
	score_label.add_theme_font_size_override("font_size", 28)
	add_child(score_label)

	# Carbon meter text
	carbon_label = Label.new()
	carbon_label.position = Vector2(24, 58)
	carbon_label.add_theme_font_size_override("font_size", 20)
	add_child(carbon_label)

	# Carbon meter bar
	carbon_bar = ProgressBar.new()
	carbon_bar.position = Vector2(24, 92)
	carbon_bar.custom_minimum_size = Vector2(360, 28)
	carbon_bar.max_value = GameState.MAX_CARBON
	carbon_bar.show_percentage = false
	carbon_bar.add_theme_stylebox_override("fill", _fill_style)
	add_child(carbon_bar)

	# Pop-up feedback text (top centre)
	feedback_label = Label.new()
	feedback_label.position = Vector2(0, 150)
	feedback_label.size = Vector2(vp.x, 40)
	feedback_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	feedback_label.add_theme_font_size_override("font_size", 30)
	feedback_label.modulate.a = 0.0
	add_child(feedback_label)

	# Game-over panel (hidden until needed)
	game_over_box = VBoxContainer.new()
	game_over_box.visible = false
	game_over_box.custom_minimum_size = Vector2(400, 0)
	game_over_box.position = Vector2(vp.x / 2.0 - 200.0, vp.y / 2.0 - 90.0)
	add_child(game_over_box)

	var title := Label.new()
	title.text = "GAME OVER: carbon limit reached!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	game_over_box.add_child(title)

	final_label = Label.new()
	final_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_label.add_theme_font_size_override("font_size", 24)
	game_over_box.add_child(final_label)

	var btn := Button.new()
	btn.text = "Play Again"
	btn.pressed.connect(func(): get_tree().reload_current_scene())
	game_over_box.add_child(btn)


func _on_score_changed(new_score: int) -> void:
	score_label.text = "Eco Score: %d" % new_score


func _on_carbon_changed(value: float) -> void:
	carbon_bar.value = value
	var ratio := value / GameState.MAX_CARBON

	var status := "LOW"
	var col := Color(0.25, 0.75, 0.35)       # green
	if ratio >= 0.7:
		status = "CRITICAL"
		col = Color(0.9, 0.25, 0.2)          # red
	elif ratio >= 0.4:
		status = "RISING"
		col = Color(0.95, 0.7, 0.15)         # amber

	_fill_style.bg_color = col
	carbon_label.text = "Carbon Level: %d%% (%s)" % [int(ratio * 100.0), status]


func _on_feedback(message: String, is_good: bool) -> void:
	var col := Color(0.2, 0.85, 0.35) if is_good else Color(0.95, 0.3, 0.25)

	# Floating message that fades out
	feedback_label.text = message
	feedback_label.modulate = col
	if _feedback_tween:
		_feedback_tween.kill()
	_feedback_tween = create_tween()
	_feedback_tween.tween_interval(0.6)
	_feedback_tween.tween_property(feedback_label, "modulate:a", 0.0, 0.5)

	# Quick screen flash
	flash.color = Color(col, 0.3)
	create_tween().tween_property(flash, "color:a", 0.0, 0.3)


func _on_game_over(final_score: int) -> void:
	final_label.text = "Final Eco Score: %d" % final_score
	game_over_box.visible = true
