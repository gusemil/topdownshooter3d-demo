extends Label

var health = 0
var armor = 0
var ammo = 0
var max_ammo = 0
var bombs = 0
var player_number = "0"
onready var player = get_node("../..")
onready var weapon_manager = player.get_node("WeaponManager")

func _ready():
	player_number = player.player_number

	weapon_manager.connect("weapon_changed", self, "update_max_ammo")
	weapon_manager.connect("bombs_changed", self, "update_bomb")

	#if player_number == "2":
	#	set_player_2_position()

func update_health(amount):
	health = amount
	update_hud()

func update_armor(amount):
	armor = amount
	update_hud()

func update_ammo(amount):
	ammo = amount
	update_hud()

func update_max_ammo(amount):
	max_ammo = amount
	update_hud()

func update_bomb(amount):
	bombs = amount
	update_hud()

func update_hud():
	if weapon_manager != null:
		if weapon_manager.current_slot == 0:
			ammo = "INF"
			max_ammo = "INF"

		text = "Player " + player_number + "\nHealth: " + str(health) + "\nArmor: " + str(armor) + "\nAmmo: " + str(ammo) + "/" + str(max_ammo) +"\nBombs: " + str(bombs) + "/3"
