extends Spatial

export var max_health : int = 100
onready var current_health : int = max_health

#signal healed
signal dead
signal hurt
signal health_changed
signal gibbed

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func take_damage(dmg : int):
	current_health -= dmg

	if(current_health <= -10):
		emit_signal("gibbed")
	elif(current_health <= 0):
		emit_signal("dead") #connectataan mm. pelaajan death funktioon
	else:
		emit_signal("hurt")

	emit_signal("health_changed", current_health)
	print("damage ", dmg, " taken. Current health: ", current_health)


