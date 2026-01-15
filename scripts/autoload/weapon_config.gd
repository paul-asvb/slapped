extends Resource
class_name WeaponConfig
## Zentrale Waffen-Konfiguration - Single Source of Truth

# === MACHINE GUN ===
@export_group("Machine Gun")
@export var mg_fire_rate: float = 10.0  # Schuss pro Sekunde
@export var mg_ammo: int = 30
@export var mg_projectile_speed: float = 80.0
@export var mg_projectile_size: float = 0.3
@export var mg_spread: float = 2.0  # Leichte Streuung in Grad

# === TREFFER-EFFEKTE ===
@export_group("Hit Effects")
@export var hit_steering_debuff_duration: float = 0.5  # Sekunden nach letztem Treffer
@export var hit_steering_multiplier: float = 0.3  # Lenkung auf 30% reduziert
@export var hit_jerk_strength: float = 0.15  # Stärke des Zuckens (Rotation pro Treffer)
@export var hit_jerk_max_angle: float = 0.785  # Max Zuck-Winkel in Radians (0.785 = 45°, also ±45° = 90° Fenster)
@export var hit_jerk_randomness: float = 0.5  # Zufälligkeit der Richtung

# === PROJEKTILE ===
@export_group("Projectiles")
@export var projectile_lifetime: float = 3.0  # Max Lebenszeit in Sekunden
@export var projectile_color: Color = Color(1.0, 0.9, 0.3)  # Gelb-Orange

# === POWER-UPS ===
@export_group("Power-Ups")
@export var pickup_respawn_next_round: bool = true  # Respawnt erst nächste Runde
@export var pickup_bob_speed: float = 2.0  # Auf/Ab-Bewegung
@export var pickup_bob_height: float = 0.5
@export var pickup_rotation_speed: float = 1.5  # Drehgeschwindigkeit
