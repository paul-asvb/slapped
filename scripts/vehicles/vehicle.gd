extends CharacterBody2D
class_name Vehicle
## Basis-Fahrzeug mit Arcade-Steuerung
## Unterstützt Beschleunigen, Bremsen, Lenken

signal destroyed()
signal hit(damage: float)
signal out_of_bounds(player_id: int)

# Leben
@export var max_lives: int = 3
var lives: int = 3
var is_eliminated: bool = false
var respawn_immunity: bool = false

# Bewegungs-Parameter
@export var max_speed: float = 400.0
@export var acceleration: float = 600.0
@export var brake_power: float = 800.0
@export var friction: float = 200.0
@export var turn_speed: float = 3.5
@export var drift_factor: float = 0.95  # 1.0 = kein Drift, 0.0 = maximaler Drift

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
	lives = max_lives
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
	# Beschleunigen / Bremsen
	var accel_input = Input.get_action_strength(input_accelerate)
	var brake_input = Input.get_action_strength(input_brake)

	if accel_input > 0:
		current_speed += acceleration * accel_input * delta
	elif brake_input > 0:
		# Rückwärts fahren wenn bereits langsam
		if current_speed > 0:
			current_speed -= brake_power * brake_input * delta
		else:
			current_speed -= acceleration * 0.5 * brake_input * delta
	else:
		# Natürliche Reibung
		current_speed = move_toward(current_speed, 0, friction * delta)

	# Geschwindigkeit begrenzen
	current_speed = clamp(current_speed, -max_speed * 0.4, max_speed)

	# Lenkung (nur wenn in Bewegung)
	steering_input = 0.0
	if abs(current_speed) > 10:
		if Input.is_action_pressed(input_left):
			steering_input = -1.0
		elif Input.is_action_pressed(input_right):
			steering_input = 1.0

		# Lenkrichtung umkehren bei Rückwärtsfahrt
		if current_speed < 0:
			steering_input *= -1

func _apply_movement(delta: float) -> void:
	# Rotation basierend auf Geschwindigkeit und Lenkung
	var turn_amount = steering_input * turn_speed * delta
	# Langsamere Lenkung bei höherer Geschwindigkeit für besseres Gefühl
	var speed_factor = 1.0 - (abs(current_speed) / max_speed) * 0.3
	rotation += turn_amount * speed_factor

	# Fahrtrichtung berechnen
	var forward = Vector2.UP.rotated(rotation)

	# Aktuelle Bewegung mit Drift-Faktor mischen
	var target_velocity = forward * current_speed
	velocity = velocity.lerp(target_velocity, 1.0 - drift_factor + 0.05)

func take_damage(amount: float) -> void:
	hit.emit(amount)

func destroy() -> void:
	destroyed.emit()

func lose_life() -> void:
	var old_lives = lives
	lives -= 1
	print("Vehicle.lose_life(): %s - %d -> %d" % [name, old_lives, lives])
	if lives <= 0:
		is_eliminated = true
		destroyed.emit()

func reset_to_spawn(spawn_pos: Vector2, spawn_rot: float = 0.0) -> void:
	position = spawn_pos
	rotation = spawn_rot
	velocity = Vector2.ZERO
	current_speed = 0
