extends Node3D
class_name Weapon
## Basis-Klasse für alle Waffen
## Wird als Child an ein Vehicle angehängt

signal ammo_changed(current: int, max_ammo: int)
signal weapon_empty()

var owner_vehicle: Vehicle
var ammo: int = 0
var max_ammo: int = 0
var is_firing: bool = false

func _ready() -> void:
	owner_vehicle = get_parent() as Vehicle

## Wird aufgerufen wenn die Waffe ausgerüstet wird
func equip(vehicle: Vehicle) -> void:
	owner_vehicle = vehicle
	_on_equip()

## Wird aufgerufen wenn die Waffe abgelegt wird
func unequip() -> void:
	_on_unequip()
	owner_vehicle = null

## Override in Subklassen
func _on_equip() -> void:
	pass

## Override in Subklassen
func _on_unequip() -> void:
	pass

## Startet das Feuern (wird gehalten)
func start_firing() -> void:
	if ammo <= 0:
		return
	is_firing = true
	_on_start_firing()

## Stoppt das Feuern
func stop_firing() -> void:
	is_firing = false
	_on_stop_firing()

## Override in Subklassen
func _on_start_firing() -> void:
	pass

## Override in Subklassen
func _on_stop_firing() -> void:
	pass

## Verbraucht Munition
func use_ammo(amount: int = 1) -> bool:
	if ammo <= 0:
		return false
	ammo -= amount
	ammo_changed.emit(ammo, max_ammo)
	if ammo <= 0:
		stop_firing()
		weapon_empty.emit()
	return true

## Gibt den Waffen-Namen zurück (für HUD)
func get_weapon_name() -> String:
	return "Weapon"

## Gibt das Waffen-Icon zurück (für HUD)
func get_weapon_icon() -> Texture2D:
	return null
