extends Spatial

export var max_health : int = 100
onready var current_health : int = max_health
export var max_armor : int = 100
export var starting_armor : int = 0
onready var current_armor : int = starting_armor

signal dead
signal take_damage
signal health_changed
#signal gibbed

var blood_spray_prefab = preload("res://scenes/BloodSpray.tscn")


func take_damage(dmg : int):
	if current_armor > 0:
		current_armor -= dmg
		if current_armor < 0:
			current_armor = 0
		print("my armor", current_armor)
		#spawn_blood_spray(dmg) #TODO: spawn armor sparks

	if current_armor <= 0:
		current_health -= dmg

		if current_health <= 0:
			#emit_signal("gibbed")
			emit_signal("dead") #connectataan mm. pelaajan death funktioon
		#elif(current_health <= 0):
			#emit_signal("dead")
		else:
			emit_signal("take_damage")

		emit_signal("health_changed", current_health)
		print("damage ", dmg, " taken. Current health: ", current_health)

	spawn_blood_spray(dmg)

func spawn_blood_spray(dmg : int, blood_modifier = 2.0):
	var blood_spray_instance = blood_spray_prefab.instance()
	var particles = blood_spray_instance.get_child(0)
	#print(particles.name)
	particles.set_amount(dmg * blood_modifier)
	get_tree().get_root().add_child(blood_spray_instance)
	blood_spray_instance.global_transform.origin = global_transform.origin + Vector3(0,2,0)


func gain_health(amount : int):
	current_health += amount
	print("hp: ", current_health)

func gain_armor(amount : int):
	current_armor += amount
	print("armor: ", current_armor)
