extends Node

onready var weapon_manager = get_node("../").get_node("WeaponManager")
onready var health_manager = get_node("../").get_node("HealthManager")
onready var player = get_node("../")

func quad_damage(powerup : Powerup):
	print("QUAD DAMAGE")
	#weapon_manager.is_quad_damage_on = true
	#weapon_manager.powerup_damage_modifier = 4

func speed_boost(powerup : Powerup):
	player.apply_speed_boost(powerup)

func undying(powerup : Powerup):
	player.apply_invulnerability(powerup)
