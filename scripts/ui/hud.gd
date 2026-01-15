extends CanvasLayer
class_name HUD
## HUD - Zeigt Punktestand, Leben, Platzierung und Rundeninformationen
## Verwendet RaceTracker für Positions-Daten

@onready var player_panels: Array[Control] = []
@onready var round_label: Label = $RoundLabel
@onready var message_label: Label = $MessageLabel

var player_count: int = 0
var player_colors: Array[Color] = []
var vehicles_ref: Array[Vehicle] = []
var race_tracker: RaceTracker

func _ready() -> void:
	GameManager.round_started.connect(_on_round_started)
	GameManager.round_ended.connect(_on_round_ended)
	GameManager.player_eliminated.connect(_on_player_eliminated)
	message_label.visible = false

func setup(vehicles: Array[Vehicle], colors: Array[Color], tracker: RaceTracker) -> void:
	player_count = vehicles.size()
	vehicles_ref = vehicles
	race_tracker = tracker

	# Panels für jeden Spieler erstellen
	for i in range(player_count):
		var color = colors[i].lightened(0.2)
		player_colors.append(color)
		var panel = _create_player_panel(i, color, vehicles[i])
		player_panels.append(panel)
		add_child(panel)

	_update_round_label()

func _create_player_panel(idx: int, player_color: Color, vehicle: Vehicle) -> Control:
	var panel = Control.new()
	panel.name = "Player%d" % (idx + 1)

	# Position basierend auf Spieler-Index
	var margin = 20
	var panel_width = 180
	panel.position = Vector2(margin + idx * (panel_width + margin), margin)

	# Farbiger Rand links
	var color_bar = ColorRect.new()
	color_bar.size = Vector2(6, 83)
	color_bar.color = player_color
	panel.add_child(color_bar)

	# Hintergrund
	var bg = ColorRect.new()
	bg.position = Vector2(6, 0)
	bg.size = Vector2(174, 83)
	bg.color = Color(0, 0, 0, 0.7)
	panel.add_child(bg)

	# Spieler-Name mit Farbe
	var name_label = Label.new()
	name_label.name = "NameLabel"
	name_label.text = "SPIELER %d" % (idx + 1)
	name_label.position = Vector2(14, 5)
	name_label.add_theme_color_override("font_color", player_color)
	name_label.add_theme_font_size_override("font_size", 16)
	panel.add_child(name_label)

	# Platz-Anzeige (Debug)
	var position_label = Label.new()
	position_label.name = "PositionLabel"
	position_label.text = "Platz: 1"
	position_label.position = Vector2(14, 25)
	position_label.add_theme_color_override("font_color", Color.YELLOW)
	panel.add_child(position_label)

	# Leben-Anzeige
	var lives_label = Label.new()
	lives_label.name = "LivesLabel"
	lives_label.text = "Leben: %d" % vehicle.lives
	lives_label.position = Vector2(14, 43)
	lives_label.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(lives_label)

	# Punkte-Anzeige
	var score_label = Label.new()
	score_label.name = "ScoreLabel"
	score_label.text = "Punkte: 0"
	score_label.position = Vector2(14, 61)
	score_label.add_theme_color_override("font_color", Color.WHITE)
	panel.add_child(score_label)

	return panel

func _process(_delta: float) -> void:
	_update_displays()

func _update_displays() -> void:
	if not race_tracker:
		return

	var positions = race_tracker.get_all_positions()

	for i in range(player_panels.size()):
		var panel = player_panels[i]
		var position_label = panel.get_node("PositionLabel") as Label
		var lives_label = panel.get_node("LivesLabel") as Label
		var score_label = panel.get_node("ScoreLabel") as Label

		var vehicle = vehicles_ref[i] if i < vehicles_ref.size() else null
		if vehicle:
			# Platzierung + Fortschritt anzeigen (Debug)
			var place = positions.get(vehicle, i + 1)
			var progress_percent = race_tracker.get_progress_percent(vehicle) * 100.0

			position_label.text = "Platz: %d (%.1f%%)" % [place, progress_percent]
			if place == 1:
				position_label.add_theme_color_override("font_color", Color.GOLD)
			else:
				position_label.add_theme_color_override("font_color", Color.WHITE)

			lives_label.text = "Leben: %d" % vehicle.lives
			if vehicle.is_eliminated:
				lives_label.add_theme_color_override("font_color", Color.RED)
				position_label.text = "Platz: - (OUT)"
			else:
				lives_label.add_theme_color_override("font_color", Color.WHITE)

		score_label.text = "Punkte: %d" % GameManager.get_score(i)

func _update_round_label() -> void:
	round_label.text = "Runde %d / %d" % [GameManager.current_round, GameManager.max_rounds]

func _on_round_started() -> void:
	_update_round_label()
	message_label.visible = false
	# Namen zurücksetzen (ohne [OUT])
	for i in range(player_panels.size()):
		var panel = player_panels[i]
		var name_label = panel.get_node("NameLabel") as Label
		name_label.text = "SPIELER %d" % (i + 1)

func _on_round_ended(winner_id: int) -> void:
	message_label.visible = true
	if winner_id >= 0:
		message_label.text = "Spieler %d gewinnt die Runde!" % (winner_id + 1)
	else:
		message_label.text = "Unentschieden!"

func _on_player_eliminated(player_id: int) -> void:
	if player_id < player_panels.size():
		var panel = player_panels[player_id]
		var name_label = panel.get_node("NameLabel") as Label
		name_label.text += " [OUT]"
