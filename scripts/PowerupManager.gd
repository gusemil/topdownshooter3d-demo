extends Node

onready var weapon_manager = get_node("../").get_node("WeaponManager")
onready var health_manager = get_node("../").get_node("HealthManager")
onready var player = get_node("../")

func quad_damage(powerup : Powerup):
	if !weapon_manager.is_quad_powerup_initialized:
		weapon_manager.init_quad_powerup(powerup)
	weapon_manager.apply_quad_damage(powerup)
	#weapon_manager.is_quad_damage_on = true
	#weapon_manager.powerup_damage_modifier = 4

func speed_boost(powerup : Powerup):
	if !player.is_speed_powerup_initialized:
		player.init_speed_powerup(powerup)
	player.apply_speed_boost(powerup)

func undying(powerup : Powerup):
	if !player.is_undying_powerup_initialized:
		player.init_undying_powerup(powerup)
	player.apply_invulnerability(powerup)
