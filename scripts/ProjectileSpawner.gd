extends Spatial

enum PROJECTILE_TYPE {FIREBALL, ROCKET}

export var projectile_type : int
var projectile_prefab
export var damage: int = 10
export var explosion_damage : int = 40
export var is_exploding_projectile = true
export var projectile_speed : float = 20

var original_damage : int = damage
var original_explosion_damage : int = explosion_damage

var bodies_to_exclude = []

var projectile_spawners = []
onready var spawner_parent = get_node("..")
var projectile_layer : int

func _ready():
	if projectile_type == PROJECTILE_TYPE.FIREBALL:
		projectile_prefab = load("res://scenes/Projectile.tscn") #Can't use preload. Preload is done during script compile time (before exports)
	elif projectile_type == PROJECTILE_TYPE.ROCKET:
		projectile_prefab = load("res://scenes/Rocket_Projectile.tscn")

	for spawner in spawner_parent.get_children():
		projectile_spawners.push_back(spawner)

func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude
	
func fire_projectile():
	var projectile_instance = projectile_prefab.instance()
	projectile_instance.set_bodies_to_exclude(bodies_to_exclude)
	projectile_instance.set_projectile_damage_on_hit(damage)
	projectile_instance.set_explosion_damage(explosion_damage)
	projectile_instance.set_is_exploding_projectile(is_exploding_projectile)
	projectile_instance.set_projectile_speed(projectile_speed)
	get_tree().get_root().add_child(projectile_instance)
	projectile_instance.global_transform = global_transform
