extends Camera2D
class_name DynamicCamera
## Kamera fokussiert auf den Führenden - konstanter Zoom für optimale Sicht

@export var default_zoom: float = 0.55  # Fester Zoom-Level für gute Sicht
@export var smooth_speed: float = 8.0   # Kamera-Reaktion
@export var look_ahead: float = 250.0   # Wie weit vor dem Führenden die Kamera schaut

var current_leader: Node2D = null

func _ready() -> void:
	position_smoothing_enabled = true
	position_smoothing_speed = smooth_speed
	zoom = Vector2(default_zoom, default_zoom)

func _process(_delta: float) -> void:
	if current_leader and is_instance_valid(current_leader):
		_update_position(current_leader)

func _update_position(leader: Node2D) -> void:
	# Kamera folgt dem Führenden mit Vorausschau in Fahrtrichtung
	var forward_dir = Vector2.UP.rotated(leader.rotation)
	var target_pos = leader.global_position + forward_dir * look_ahead
	global_position = target_pos

func set_leader(leader: Node2D) -> void:
	current_leader = leader

func clear_leader() -> void:
	current_leader = null
