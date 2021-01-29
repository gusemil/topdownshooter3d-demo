extends Spatial

enum WEAPON_SLOTS {MACHINE_GUN, SHOTGUN, ROCKET_LAUNCHER}

#var slots_unlocked = {
#	WEAPON_SLOTS.MACHINE_GUN: true,
#	WEAPON_SLOTS.SHOTGUN: false,
#	WEAPON_SLOTS.ROCKET_LAUNCHER: false,
#}

onready var weapons = $Weapons.get_children()

var current_slot = 0
var current_weapon = null
var fire_point : Spatial
var collision_bodies_to_ignore : Array = []

func _process(delta):
	if Input.is_action_just_pressed("weapon1") and current_slot != WEAPON_SLOTS.MACHINE_GUN:
		change_weapon(WEAPON_SLOTS.MACHINE_GUN)
	elif Input.is_action_just_pressed("weapon2") and current_slot != WEAPON_SLOTS.SHOTGUN:
		change_weapon(WEAPON_SLOTS.SHOTGUN)
	elif Input.is_action_just_pressed("weapon3") and current_slot != WEAPON_SLOTS.ROCKET_LAUNCHER:
		change_weapon(WEAPON_SLOTS.ROCKET_LAUNCHER)

func init(_fire_point: Spatial, _collision_bodies_to_ignore: Array):
	fire_point = _fire_point
	collision_bodies_to_ignore = _collision_bodies_to_ignore
	current_weapon = weapons[0]
	current_slot = 0
	current_weapon.set_active()
	#change_weapon(WEAPON_SLOTS.MACHINE_GUN)
	print($Weapons.get_child_count())
	print(current_weapon)
	
	current_weapon = weapons[current_slot]
	
	for weapon in weapons:
		if weapon.has_method("init"):
			weapon.init(_fire_point, _collision_bodies_to_ignore)
	
#	if current_weapon.has_method("set_active"):
#		current_weapon.set_active()
#	else:
#		current_weapon.show()

func shoot(attack_input_just_pressed: bool, attack_input_held: bool):
	if current_weapon.has_method("shoot"):
		current_weapon.shoot(attack_input_just_pressed, attack_input_held)

func change_weapon(new_weapon_index : int):
	#if new_weapon_index != current_slot:
	print("Current weapon: ", current_slot, " new weapon: ", new_weapon_index)
	current_weapon.set_inactive()
	current_slot = new_weapon_index
	current_weapon = weapons[current_slot]
	current_weapon.set_active()
