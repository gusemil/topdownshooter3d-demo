extends Spatial

export var max_health : int = 100
onready var current_health : int = max_health

#signal healed
signal dead
signal take_damage
signal health_changed
#signal gibbed

var blood_spray_prefab = preload("res://scenes/BloodSpray.tscn")

func take_damage(dmg : int):
	current_health -= dmg

	if(current_health <= -10):
		#emit_signal("gibbed")
		emit_signal("dead") #connectataan mm. pelaajan death funktioon
	elif(current_health <= 0):
		emit_signal("dead") #connectataan mm. pelaajan death funktioon
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
