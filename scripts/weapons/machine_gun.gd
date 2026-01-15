extends Weapon
class_name MachineGun
## Maschinengewehr - Feuert schnelle Projektile aus beiden Frontscheinwerfern

const ProjectileScene = preload("res://scenes/weapons/projectile.tscn")

var fire_timer: float = 0.0
var fire_interval: float = 0.1  # Wird aus Config geladen
var current_barrel: int = 0  # Wechselt zwischen links (0) und rechts (1)

# Mündungspositionen relativ zum Fahrzeug (Frontscheinwerfer)
var muzzle_offsets: Array[Vector3] = [
	Vector3(-0.6, 0.3, -1.5),  # Links vorne
	Vector3(0.6, 0.3, -1.5),   # Rechts vorne
]

func _ready() -> void:
	super._ready()
	var cfg = GameManager.weapon_config
	max_ammo = cfg.mg_ammo
	ammo = max_ammo
	fire_interval = 1.0 / cfg.mg_fire_rate

func _on_equip() -> void:
	ammo_changed.emit(ammo, max_ammo)

func _process(delta: float) -> void:
	if not is_firing or not owner_vehicle or not is_instance_valid(owner_vehicle):
		return

	if ammo <= 0:
		stop_firing()
		return

	fire_timer -= delta
	if fire_timer <= 0:
		_fire_projectile()
		fire_timer = fire_interval

func _on_start_firing() -> void:
	fire_timer = 0  # Sofort feuern

func _fire_projectile() -> void:
	if not owner_vehicle or not is_instance_valid(owner_vehicle):
		stop_firing()
		return

	if not use_ammo():
		return

	# Nach use_ammo() nochmal prüfen - Signal könnte owner_vehicle auf null gesetzt haben
	if not owner_vehicle or not is_instance_valid(owner_vehicle):
		return

	var cfg = GameManager.weapon_config

	# Mündungsposition berechnen (wechselt zwischen links/rechts)
	var muzzle_offset = muzzle_offsets[current_barrel]
	current_barrel = (current_barrel + 1) % 2

	# Globale Position berechnen
	var muzzle_pos = owner_vehicle.global_transform * muzzle_offset

	# Schussrichtung = Fahrzeug-Vorwärtsrichtung mit leichter Streuung
	var forward = -owner_vehicle.global_transform.basis.z
	var spread_rad = deg_to_rad(cfg.mg_spread)
	var spread = Vector3(
		randf_range(-spread_rad, spread_rad),
		0,
		randf_range(-spread_rad, spread_rad)
	)
	var direction = (forward + spread).normalized()

	# Projektil spawnen
	var projectile = ProjectileScene.instantiate() as Projectile
	var tree = owner_vehicle.get_tree()
	if not tree:
		projectile.queue_free()
		return
	tree.root.add_child(projectile)
	projectile.global_position = muzzle_pos
	projectile.setup(direction, cfg.mg_projectile_speed, owner_vehicle)

	# TODO: Mündungsfeuer-Effekt
	# TODO: Schuss-Sound

func get_weapon_name() -> String:
	return "Machine Gun"
