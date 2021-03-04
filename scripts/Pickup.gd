extends Area

class_name Pickup

enum PICKUP_TYPES {AMMO_MINIGUN, AMMO_SHOTGUN, AMMO_ROCKET_LAUNCHER, HEALTH, ARMOR, BOSS, BOMB}

export(PICKUP_TYPES) var pickup_type
export var amount = 0
export var life_time = 10

var pickup_removal_timer : Timer

func _ready():
	pickup_removal_timer = Timer.new()
	pickup_removal_timer.wait_time = life_time
	pickup_removal_timer.connect("timeout", self, "remove_pickup")
	add_child(pickup_removal_timer)
	pickup_removal_timer.start()

func remove_pickup():
	queue_free()
