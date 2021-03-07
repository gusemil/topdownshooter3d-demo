extends Node

var upgrade_count = 0

onready var upgrade_hud = $UpgradeHUDController
onready var player = get_tree().get_root()

var upgrades = []

const upgrade_class = preload("res://scripts/Upgrade.gd")

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	var buttons = upgrade_hud.get_children()
	
	for button in buttons:
		var created_upgrade = create_random_upgrade()
		upgrades.push_back(created_upgrade)
		var label : Label = button.get_child(0)
		label.text = created_upgrade.description
		

func apply_upgrade(upgrade_number : int):
	hide_upgrades()
	print("upgrade index: ", upgrade_number)

func test():
	print("TEEST")



func create_random_upgrade():
	var upgrade = upgrade_class.new()

	print("UGPRADE SIZE: ", upgrade.UPGRADE_TYPES.size())
	var random = rng.randi_range(0,upgrade.UPGRADE_TYPES.size() -1)
	
	if random == upgrade.UPGRADE_TYPES.HEALTH:
		upgrade.set_effect_and_description(25, "Health +25")
	elif random == upgrade.UPGRADE_TYPES.ARMOR:
		upgrade.set_effect_and_description(25, "Armor +25")
	elif random == upgrade.UPGRADE_TYPES.AMMO:
		upgrade.set_effect_and_description(10.0, "Max Ammo +10.0%")
	elif random == upgrade.UPGRADE_TYPES.SPEED:
		upgrade.set_effect_and_description(10.0, "Speed boost +10.0%")
	elif random == upgrade.UPGRADE_TYPES.WEAPON_DMG:
		upgrade.set_effect_and_description(10.0, "Weapon dmg: +10.0%")

	return upgrade


func show_upgrades():
	upgrade_hud.show()

func hide_upgrades():
	upgrade_hud.hide()

