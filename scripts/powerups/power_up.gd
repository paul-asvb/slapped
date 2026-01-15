extends Area3D
class_name PowerUp
## Basis-Klasse für alle Power-Ups auf der Strecke

signal collected(by_vehicle: Vehicle)

@export var respawn_next_round: bool = true
var is_active: bool = true
var initial_position: Vector3
var bob_time: float = 0.0

func _ready() -> void:
	initial_position = global_position
	body_entered.connect(_on_body_entered)
	GameManager.round_started.connect(_on_round_started)

func _process(delta: float) -> void:
	if not is_active:
		return

	var cfg = GameManager.weapon_config

	# Auf/Ab-Bewegung
	bob_time += delta * cfg.pickup_bob_speed
	var bob_offset = sin(bob_time) * cfg.pickup_bob_height
	global_position.y = initial_position.y + bob_offset + 1.0  # +1 damit es über dem Boden schwebt

	# Rotation
	rotation.y += cfg.pickup_rotation_speed * delta

func _on_body_entered(body: Node3D) -> void:
	if not is_active:
		return

	if body is Vehicle:
		var vehicle = body as Vehicle
		if _can_collect(vehicle):
			_on_collected(vehicle)
			collected.emit(vehicle)
			_deactivate()

## Override in Subklassen - Prüft ob Vehicle dieses PowerUp einsammeln kann
func _can_collect(vehicle: Vehicle) -> bool:
	return true

## Override in Subklassen - Wird aufgerufen wenn eingesammelt
func _on_collected(vehicle: Vehicle) -> void:
	pass

func _deactivate() -> void:
	is_active = false
	visible = false
	# Kollision deaktivieren
	set_deferred("monitoring", false)

func _activate() -> void:
	is_active = true
	visible = true
	set_deferred("monitoring", true)
	global_position = initial_position

func _on_round_started() -> void:
	if respawn_next_round:
		_activate()
