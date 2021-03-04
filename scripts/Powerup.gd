extends Area

class_name Powerup

enum POWERUP_TYPES {QUAD_DAMAGE, UNDYING, SPEED_BOOST, BULLET_TIME}

export(POWERUP_TYPES) var powerup_type
export var length : float
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
