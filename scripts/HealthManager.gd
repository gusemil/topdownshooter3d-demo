extends Spatial

export var max_health : int = 100
onready var current_health : int = max_health
export var max_armor : int = 100
export var starting_armor : int = 0
onready var current_armor : int = starting_armor

signal dead
signal take_damage
signal health_changed
signal health_damage
signal armor_damage
#signal gibbed

var blood_spray_prefab = preload("res://scenes/BloodSpray.tscn")

#Sounds
onready var soundmanager = get_tree().get_root().get_node("World/NonPositionalSoundManager")

func take_damage(dmg : int):
	if current_armor > 0:
		var armor_before_dmg = current_armor
		print("DMG BEFORE ARMOR: ", dmg)
		current_armor -= dmg
		dmg -= armor_before_dmg
		if current_armor < 0:
			current_armor = 0
		print("my armor", current_armor)
		emit_signal("armor_damage")
		#spawn_armor_sparks(dmg) #TODO: spawn armor sparks

		print("FINAL DAMAGE: ", dmg)


	if current_armor <= 0 and dmg > 0:
		current_health -= dmg
		emit_signal("health_damage")

		if current_health <= 0:
			#emit_signal("gibbed")
			emit_signal("dead") #connectataan mm. pelaajan death funktioon
		#elif(current_health <= 0):
			#emit_signal("dead")
		else:
			emit_signal("take_damage")

		emit_signal("health_changed", current_health)
		print("Object: ", name , " damage taken: ", dmg , " current_health: ", current_health)
		spawn_blood_spray(dmg)

func spawn_blood_spray(dmg : int, blood_modifier = 2.0):
	var blood_spray_instance = blood_spray_prefab.instance()
	var particles = blood_spray_instance.get_child(0)
	#print(particles.name)
	particles.set_amount(dmg * blood_modifier)
	get_tree().get_root().add_child(blood_spray_instance)
	blood_spray_instance.global_transform.origin = global_transform.origin + Vector3(0,2,0)


func gain_health(pickup : Pickup):
	if current_health < max_health:
		if current_health + pickup.amount <= max_health:
			current_health += pickup.amount
		else:
			current_health = max_health
		print("hp: ", current_health)
		soundmanager.play_sound(1,3)
		pickup.queue_free()

func gain_armor(pickup : Pickup):
	if current_armor < max_armor:
		if current_armor + pickup.amount <= max_armor:
			current_armor += pickup.amount
		else:
			current_armor = max_armor
		print("armor: ", current_armor)
		soundmanager.play_sound(1,4)
		pickup.queue_free()
		
