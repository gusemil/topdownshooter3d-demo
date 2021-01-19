extends Spatial

enum WEAPON_SLOTS {MACHINE_GUN, SHOTGUN, ROCKET_LAUNCHER}
var slots_unlocked = {
	WEAPON_SLOTS.MACHINE_GUN: true,
	WEAPON_SLOTS.SHOTGUN: false,
	WEAPON_SLOTS.ROCKET_LAUNCHER: false,
}

onready var weapons = $Weapons.get_children()

var current_slot = 0
var current_weapon = null

func init(_fire_point: Spatial, _bodies_to_exclude: Array):
	current_weapon = WEAPON_SLOTS.MACHINE_GUN
	print($Weapons.get_child_count())
	print(current_weapon)
	
	current_weapon = weapons[current_weapon]
	if current_weapon.has_method("set_active"):
		current_weapon.set_active()
	else:
		current_weapon.show()

func shoot(attack_input_just_pressed: bool, attack_input_held: bool):
	if current_weapon.has_method("shoot"):
		current_weapon.shoot(attack_input_just_pressed, attack_input_held)
