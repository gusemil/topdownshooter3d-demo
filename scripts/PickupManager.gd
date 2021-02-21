extends Area

onready var weapon_manager = get_node("../").get_node("WeaponManager")
onready var health_manager = get_node("../").get_node("HealthManager")
onready var powerup_manager = get_node("../").get_node("PowerupManager")

#Sounds
onready var soundmanager = get_tree().get_root().get_node("World/NonPositionalSoundManager")

onready var player_canvas_layer = get_node("../CanvasLayer")

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
		elif pickup.pickup_type == pickup.PICKUP_TYPES.BOSS:
			weapon_manager.add_ammo_boss(0,300)
			weapon_manager.add_ammo_boss(1,300)
			weapon_manager.add_ammo_boss(2,300)
			health_manager.gain_health(pickup)
			health_manager.gain_armor(pickup)
			soundmanager.play_sound(1,11)
			player_canvas_layer.show_pickup_hud("BOSS REFILL")
			pickup.queue_free()
		elif pickup.pickup_type == pickup.PICKUP_TYPES.BOMB:
			weapon_manager.add_bomb(pickup)
	elif pickup is Powerup:
		if pickup.powerup_type == pickup.POWERUP_TYPES.QUAD_DAMAGE:
			powerup_manager.quad_damage(pickup)
		elif pickup.powerup_type == pickup.POWERUP_TYPES.UNDYING:
			powerup_manager.undying(pickup)
		elif pickup.powerup_type == pickup.POWERUP_TYPES.SPEED_BOOST:
			powerup_manager.speed_boost(pickup)
