extends Spatial

#enum PROJECTILE_TYPES {ROCKET, FIREBALL}

var projectile_prefab

var bodies_to_exclude = []
func _ready():
	projectile_prefab = load("res://scenes/Projectile.tscn") #Ei voi käyttää preload mitenkään. Preload suoritetaan scriptin compilen aikana (ennen exportteja)

func set_bodies_to_exclude(_bodies_to_exclude : Array):
	bodies_to_exclude = _bodies_to_exclude

func fire_projectile():
	print("firing projectile!")
	var projectile_instance = projectile_prefab.instance()
	projectile_instance.set_bodies_to_exclude(bodies_to_exclude)
	get_tree().get_root().add_child(projectile_instance)
	projectile_instance.global_transform = global_transform
