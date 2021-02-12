extends Label

var health = 0
var armor = 0
var ammo = 0

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
	text = "Health: " + str(health) + "\nArmor: " + str(armor) + "\nAmmo: " + str(ammo)
