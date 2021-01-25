extends Spatial

enum PROJECTILE_TYPE {FIREBALL, ROCKET}

export var projectile_type : int
var projectile_prefab
export var damage: int = 10
export var explosion_damage : int = 40
export var is_exploding_projectile = true

var bodies_to_exclude = []
func set_bodies_to_exclude(_bodies_to_exclude : Array):
	bodies_to_exclude = _bodies_to_exclude
	
func set_projectile_damage(_damage : int):
	damage = _damage
	
func _ready():
	if projectile_type == PROJECTILE_TYPE.FIREBALL:
		projectile_prefab = load("res://scenes/Projectile.tscn") #Ei voi käyttää preload mitenkään. Preload suoritetaan scriptin compilen aikana (ennen exportteja)
	elif projectile_type == PROJECTILE_TYPE.ROCKET:
		print("TODO ROCKET")
	
func fire_projectile():
	#print("firing projectile!")
	var projectile_instance = projectile_prefab.instance()
	projectile_instance.set_bodies_to_exclude(bodies_to_exclude)
	projectile_instance.set_projectile_damage_on_hit(damage)
	projectile_instance.set_explosion_damage(explosion_damage)
	projectile_instance.set_is_exploding_projectile(is_exploding_projectile)
	get_tree().get_root().add_child(projectile_instance)
	projectile_instance.global_transform = global_transform
