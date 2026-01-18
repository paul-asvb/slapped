extends PowerUp
class_name WeaponPickup
## Gibt dem Fahrzeug eine Waffe wenn eingesammelt

enum WeaponType { MACHINE_GUN, RAY_GUN }

@export var weapon_type: WeaponType = WeaponType.MACHINE_GUN

func _can_collect(vehicle: Vehicle) -> bool:
	# Kann nur einsammeln wenn keine Waffe aktiv
	return vehicle.current_weapon == null

func _on_collected(vehicle: Vehicle) -> void:
	match weapon_type:
		WeaponType.MACHINE_GUN:
			var weapon = MachineGun.new()
			vehicle.equip_weapon(weapon)
		WeaponType.RAY_GUN:
			var weapon = RayGun.new()
			vehicle.equip_weapon(weapon)
