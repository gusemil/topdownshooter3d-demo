class_name Upgrade

enum UPGRADE_TYPES {HEALTH, ARMOR, AMMO, SPEED, WEAPON_DMG}

export(UPGRADE_TYPES) var type
export(String) var description
export var effect_value = 0

func set_effect_and_description(val, text : String):
	effect_value = val
	description = text
