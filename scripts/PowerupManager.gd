extends Node

onready var weapon_manager = get_node("../").get_node("WeaponManager")
onready var health_manager = get_node("../").get_node("HealthManager")
onready var player = get_node("../")

func quad_damage():
	print("QUAD DAMAGE")

func speed_boost():
	print("SPEED BOOST")

func undying():
	print("UNDYING")
