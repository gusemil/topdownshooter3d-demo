extends Area

onready var weapon_manager = get_node("../").get_node("WeaponManager")
onready var health_manager = get_node("../").get_node("HealthManager")
onready var powerup_manager = get_node("../").get_node("PowerupManager")

func _ready():
	connect("area_entered", self, "on_pickup")
	
func on_pickup(pickup):
	if pickup is Pickup:
		if pickup.pickup_type == pickup.PICKUP_TYPES.AMMO_MACHINE_GUN || pickup.pickup_type == pickup.PICKUP_TYPES.AMMO_SHOTGUN ||pickup.pickup_type == pickup.PICKUP_TYPES.AMMO_ROCKET_LAUNCHER:
			weapon_manager.add_ammo(pickup)
		elif pickup.pickup_type == pickup.PICKUP_TYPES.HEALTH:
			health_manager.gain_health(pickup)
		elif pickup.pickup_type == pickup.PICKUP_TYPES.ARMOR:
			health_manager.gain_armor(pickup)
	elif pickup is Powerup:
		if pickup.powerup_type == pickup.POWERUP_TYPES.QUAD_DAMAGE:
			powerup_manager.quad_damage()
			#weapon_manager.add_ammo(powerup.amount, powerup.powerup_TYPES.AMMO_MACHINE_GUN)
		elif pickup.powerup_type == pickup.POWERUP_TYPES.UNDYING:
			powerup_manager.undying()
			#weapon_manager.add_ammo(powerup.amount, powerup.powerup_TYPES.AMMO_SHOTGUN)
		elif pickup.powerup_type == pickup.POWERUP_TYPES.SPEED_BOOST:
			powerup_manager.speed_boost()
