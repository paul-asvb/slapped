extends Camera2D
class_name DynamicCamera
## Kamera fokussiert auf den Führenden im Rennen
## Verwendet RaceTracker für die Leader-Ermittlung

@export var default_zoom: float = 0.55  # Fester Zoom-Level für gute Sicht
@export var smooth_speed: float = 8.0   # Kamera-Reaktion
@export var look_ahead: float = 250.0   # Wie weit vor dem Führenden die Kamera schaut

var race_tracker: RaceTracker

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = smooth_speed
	zoom = Vector2(default_zoom, default_zoom)

func setup(tracker: RaceTracker) -> void:
	race_tracker = tracker

func _process(_delta: float) -> void:
	if not race_tracker:
		return

	var leader = race_tracker.get_leader()
	if leader:
		_update_position(leader)

func _update_position(leader: Node2D) -> void:
	# Kamera folgt dem Führenden mit Vorausschau in Fahrtrichtung
	var forward_dir = Vector2.UP.rotated(leader.rotation)
	var target_pos = leader.global_position + forward_dir * look_ahead
	global_position = target_pos
