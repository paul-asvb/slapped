extends CharacterBody3D
class_name Vehicle
## Basis-Fahrzeug mit Arcade-Steuerung (3D)
## Bewegung auf X/Z-Ebene mit Sprung-Physik

signal destroyed()
signal hit(damage: float)
signal out_of_bounds(player_id: int)

# Leben
var lives: int = 3
var is_eliminated: bool = false
var respawn_immunity: bool = false

# Bewegungs-Parameter (nicht-konfigurierbar)
var friction: float = 20.0
var turn_speed: float = 3.5
var drift_factor: float = 0.95
var ground_y: float = 0.0

# Runtime
var vertical_velocity: float = 0.0
var is_airborne: bool = false

# Spieler-Zuordnung
@export var player_id: int = 0

# Input-Actions (werden pro Spieler gesetzt)
var input_accelerate: String = "accelerate"
var input_brake: String = "brake"
var input_left: String = "steer_left"
var input_right: String = "steer_right"

# Interner Zustand
var current_speed: float = 0.0
var steering_input: float = 0.0

func _ready() -> void:
	lives = GameManager.config.max_lives
	_setup_input_actions()

func _setup_input_actions() -> void:
	# Input-Actions basierend auf player_id setzen
	var suffix = "" if player_id == 0 else "_p" + str(player_id + 1)
	input_accelerate = "accelerate" + suffix
	input_brake = "brake" + suffix
	input_left = "steer_left" + suffix
	input_right = "steer_right" + suffix

func _physics_process(delta: float) -> void:
	_handle_input(delta)
	_apply_movement(delta)
	move_and_slide()

func _handle_input(delta: float) -> void:
	var cfg = GameManager.config
	var accel_input = Input.get_action_strength(input_accelerate)
	var brake_input = Input.get_action_strength(input_brake)

	if accel_input > 0:
		current_speed += cfg.vehicle_acceleration * accel_input * delta
	elif brake_input > 0:
		if current_speed > 0:
			current_speed -= cfg.vehicle_brake_power * brake_input * delta
		else:
			current_speed -= cfg.vehicle_acceleration * 0.5 * brake_input * delta
	else:
		current_speed = move_toward(current_speed, 0, friction * delta)

	current_speed = clamp(current_speed, -cfg.vehicle_max_speed * 0.4, cfg.vehicle_max_speed)

	# Lenkung (nur wenn in Bewegung)
	steering_input = 0.0
	if abs(current_speed) > 1:
		if Input.is_action_pressed(input_left):
			steering_input = -1.0
		elif Input.is_action_pressed(input_right):
			steering_input = 1.0

		# Lenkrichtung umkehren bei Rückwärtsfahrt
		if current_speed < 0:
			steering_input *= -1

func _apply_movement(delta: float) -> void:
	# Rotation um Y-Achse (horizontales Drehen)
	var turn_amount = steering_input * turn_speed * delta
	var speed_factor = 1.0 - (abs(current_speed) / GameManager.config.vehicle_max_speed) * 0.3
	rotation.y -= turn_amount * speed_factor

	# Fahrtrichtung berechnen (vorwärts ist -Z in Godot 3D)
	var forward = -transform.basis.z

	# Horizontale Bewegung
	var target_velocity = forward * current_speed
	velocity.x = lerpf(velocity.x, target_velocity.x, 1.0 - drift_factor + 0.05)
	velocity.z = lerpf(velocity.z, target_velocity.z, 1.0 - drift_factor + 0.05)

	# Vertikale Bewegung (Sprung-Physik)
	if is_on_floor():
		is_airborne = false
		vertical_velocity = 0.0
		# Rampen-Erkennung: Wenn wir auf einer Schräge sind, bekommen wir Auftrieb
		var floor_normal = get_floor_normal()
		if floor_normal.y < 0.95 and current_speed > 5.0:  # Schräge + Geschwindigkeit
			var ramp_boost = current_speed * (1.0 - floor_normal.y) * 0.8
			vertical_velocity = ramp_boost
	else:
		# Nur Gravitation anwenden wenn wir über dem Boden sind
		if global_position.y > ground_y + 0.5:
			is_airborne = true
			vertical_velocity -= GameManager.config.vehicle_gravity * delta
		else:
			global_position.y = ground_y
			vertical_velocity = 0.0
			is_airborne = false

	velocity.y = vertical_velocity

func take_damage(amount: float) -> void:
	hit.emit(amount)

func destroy() -> void:
	destroyed.emit()

func lose_life() -> void:
	lives -= 1
	if lives <= 0:
		is_eliminated = true
		destroyed.emit()

func reset_to_spawn(spawn_pos: Vector3, spawn_rot: float = 0.0) -> void:
	global_position = spawn_pos
	rotation.y = spawn_rot
	velocity = Vector3.ZERO
	current_speed = 0
