extends Weapon
class_name RayGun
## Raygun Waffe - kurzer Strahl-Burst der alle Fahrzeuge im Pfad in die Luft schleudert

var shapecast: ShapeCast3D
var beam_mesh: MeshInstance3D
var beam_range: float = 35.0
var beam_radius: float = 0.5  # Radius für Multi-Hit
var launch_force: float = 60.0
var launch_duration: float = 2.5
var beam_color: Color = Color(0.2, 0.8, 1.0)

# Burst-Modus
var burst_duration: float = 0.3  # Sekunden pro Schuss
var burst_timer: float = 0.0
var is_bursting: bool = false
var hit_vehicles_this_burst: Array[Vehicle] = []  # Verhindert Mehrfach-Hits


func _ready() -> void:
	super._ready()
	var cfg = GameManager.weapon_config
	max_ammo = cfg.raygun_ammo
	ammo = max_ammo
	beam_range = cfg.raygun_range
	beam_radius = cfg.raygun_beam_radius
	launch_force = cfg.raygun_launch_force
	launch_duration = cfg.raygun_launch_duration
	beam_color = cfg.raygun_beam_color
	burst_duration = cfg.raygun_burst_duration
	_setup_shapecast()
	_setup_beam_visual()


func _setup_shapecast() -> void:
	shapecast = ShapeCast3D.new()

	# Zylindrische Form für den Strahl
	var shape = CylinderShape3D.new()
	shape.radius = beam_radius
	shape.height = beam_range
	shapecast.shape = shape

	# Zylinder ist vertikal, wir rotieren ihn nach vorne
	shapecast.rotation_degrees.x = 90
	shapecast.position.z = -beam_range / 2.0  # Zentriert vor dem Fahrzeug

	shapecast.collision_mask = 1  # Fahrzeuge Layer
	shapecast.max_results = 10  # Bis zu 10 Fahrzeuge gleichzeitig
	shapecast.enabled = false
	add_child(shapecast)


func _setup_beam_visual() -> void:
	beam_mesh = MeshInstance3D.new()
	var cylinder = CylinderMesh.new()
	cylinder.top_radius = beam_radius
	cylinder.bottom_radius = beam_radius
	cylinder.height = beam_range
	beam_mesh.mesh = cylinder
	beam_mesh.visible = false

	# Position: zentriert vor dem Fahrzeug
	beam_mesh.position.z = -beam_range / 2.0
	beam_mesh.rotation_degrees.x = 90

	# Gluehendes Material
	var mat = StandardMaterial3D.new()
	mat.albedo_color = beam_color
	mat.emission_enabled = true
	mat.emission = beam_color
	mat.emission_energy_multiplier = 3.0
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.8
	beam_mesh.material_override = mat
	add_child(beam_mesh)


func _process(delta: float) -> void:
	if not owner_vehicle:
		return

	# Burst-Timer verarbeiten
	if is_bursting:
		burst_timer -= delta
		_update_beam()

		if burst_timer <= 0:
			_end_burst()


func _on_start_firing() -> void:
	# Neuen Burst starten
	if not is_bursting and ammo > 0:
		_start_burst()


func _start_burst() -> void:
	is_bursting = true
	burst_timer = burst_duration
	hit_vehicles_this_burst.clear()

	# Munition manuell verbrauchen (ohne sofortiges weapon_empty)
	ammo -= 1
	ammo_changed.emit(ammo, max_ammo)

	# Visuals aktivieren
	beam_mesh.visible = true
	shapecast.enabled = true


func _end_burst() -> void:
	is_bursting = false
	burst_timer = 0.0
	hit_vehicles_this_burst.clear()
	_deactivate_beam()
	stop_firing()

	# Erst nach Burst-Ende prüfen ob Waffe leer
	if ammo <= 0:
		weapon_empty.emit()


func _update_beam() -> void:
	shapecast.force_shapecast_update()

	# Alle getroffenen Fahrzeuge verarbeiten
	var collision_count = shapecast.get_collision_count()
	for i in range(collision_count):
		var collider = shapecast.get_collider(i)
		if collider is Vehicle and collider != owner_vehicle:
			# Nur einmal pro Burst treffen
			if not hit_vehicles_this_burst.has(collider):
				hit_vehicles_this_burst.append(collider)
				# Trefferrichtung: vom Schützen zum Ziel
				var hit_direction = (collider.global_position - owner_vehicle.global_position).normalized()
				collider.launch_into_air(launch_force, launch_duration, hit_direction)


func _deactivate_beam() -> void:
	beam_mesh.visible = false
	shapecast.enabled = false


func _on_stop_firing() -> void:
	# Burst laeuft weiter bis Timer abgelaufen
	pass


func get_weapon_name() -> String:
	return "Ray Gun"
