extends Area

onready var weapon_manager = get_node("../").get_node("WeaponManager")
onready var health_manager = get_node("../").get_node("HealthManager")

func _ready():
	connect("area_entered", self, "on_pickup")
	
func on_pickup(pickup : Pickup):
	if pickup.pickup_type == pickup.PICKUP_TYPES.AMMO_MACHINE_GUN:
		print(weapon_manager.name)
		weapon_manager.add_ammo(pickup.amount, pickup.PICKUP_TYPES.AMMO_MACHINE_GUN)
	elif pickup.pickup_type == pickup.PICKUP_TYPES.AMMO_SHOTGUN:
		print(weapon_manager.name)
		weapon_manager.add_ammo(pickup.amount, pickup.PICKUP_TYPES.AMMO_SHOTGUN)
	elif pickup.pickup_type == pickup.PICKUP_TYPES.AMMO_ROCKET_LAUNCHER:
		print(weapon_manager.name)
		weapon_manager.add_ammo(pickup.amount, pickup.PICKUP_TYPES.AMMO_ROCKET_LAUNCHER)
	elif pickup.PICKUP_TYPES.HEALTH:
		health_manager.gain_health(pickup.amount)
	elif pickup.PICKUP_TYPES.ARMOR:
		health_manager.gain_armor(pickup.amount)

	pickup.queue_free()
