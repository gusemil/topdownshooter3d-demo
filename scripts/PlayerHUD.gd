extends Label

var health = 0
var armor = 0
var ammo = 0
var max_ammo = 200
var player_number = "0"
onready var player = get_node("../..")

func _ready():
	player_number = player.player_number

	if player_number == "2":
		set_player_2_position()

func update_health(amount):
	health = amount
	update_hud()

func update_armor(amount):
	armor = amount
	update_hud()

func update_ammo(amount):
	ammo = amount
	update_hud()


func update_hud():
	text = "Player " + player_number + "\nHealth: " + str(health) + "\nArmor: " + str(armor) + "\nAmmo: " + str(ammo) + "/" + str(max_ammo)

func set_player_2_position():
	self.margin_left = 530
	self.margin_top = 300
	self.margin_right = 630
	self.margin_bottom = 460
