extends Area

class_name Pickup

enum PICKUP_TYPES {HEALTH, ARMOR, AMMO_MACHINE_GUN, AMMO_SHOTGUN, AMMO_ROCKET_LAUNCHER}

export(PICKUP_TYPES) var pickup_type
export var amount = 0
