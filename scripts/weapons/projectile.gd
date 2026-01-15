extends Area3D
class_name Projectile
## Projektil für Maschinengewehr und andere Waffen

var direction: Vector3 = Vector3.FORWARD
var speed: float = 80.0
var owner_vehicle: Vehicle
var lifetime: float = 3.0

func _ready() -> void:
	# Kollisions-Signale verbinden
	body_entered.connect(_on_body_entered)

	# Farbe aus Config setzen
	var cfg = GameManager.weapon_config
	var mesh = $MeshInstance3D as MeshInstance3D
	if mesh and mesh.material_override:
		var mat = mesh.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color = cfg.projectile_color
			mat.emission = cfg.projectile_color

	# Lifetime Timer starten
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_expired)

func setup(dir: Vector3, spd: float, owner: Vehicle) -> void:
	direction = dir.normalized()
	speed = spd
	owner_vehicle = owner
	lifetime = GameManager.weapon_config.projectile_lifetime

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node3D) -> void:
	if body == owner_vehicle:
		return  # Ignoriere eigenes Fahrzeug

	if body is Vehicle:
		var vehicle = body as Vehicle
		vehicle.on_projectile_hit(owner_vehicle)
		_destroy()
	elif body is StaticBody3D:
		# Wand getroffen
		_destroy()

func _on_lifetime_expired() -> void:
	_destroy()

func _destroy() -> void:
	# TODO: Treffer-Partikel spawnen
	queue_free()
