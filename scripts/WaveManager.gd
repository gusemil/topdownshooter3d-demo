extends Node

var melee_enemy_prefab = preload("res://scenes/MeleeEnemy.tscn")
var ranged_enemy_prefab = preload("res://scenes/RangedEnemy.tscn")
var navmesh

enum ENEMIES {MELEE, RANGED}

var spawns_per_wave : int = 1
var enemies_per_spawn : int = 1
var spawn_timer : float = 1.0

var enemy_prefabs = []

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	navmesh = get_tree().get_root().get_node("World/Navigation")
	enemy_prefabs.push_back(melee_enemy_prefab)
	enemy_prefabs.push_back(ranged_enemy_prefab)

	spawn_random_enemy()
	spawn_random_enemy()
	spawn_random_enemy()

func spawn_random_enemy():
	var direction = rng.randi_range(0,3)
	var spawn_point : Vector3

	print("DIRECTION: ", direction)
	if(direction == 0):
		spawn_point = Vector3(rng.randi_range(-47,47),0,rng.randi_range(-47,-40))
	elif(direction == 1):
		spawn_point = Vector3(rng.randi_range(-47,-40),0,rng.randi_range(-47,47))
	elif(direction == 2):
		spawn_point = Vector3(rng.randi_range(-47,47),0,rng.randi_range(40,47))
	elif(direction == 3):
		spawn_point = Vector3(rng.randi_range(40,47),0,rng.randi_range(-47,47))

	var enemy_instance = enemy_prefabs[rand_range(0, enemy_prefabs.size())].instance()
	navmesh.add_child(enemy_instance)
	enemy_instance.global_transform.origin = spawn_point
	print(enemy_instance.name)

	#var projectile_instance = projectile_prefab.instance()
	#get_tree().get_root().add_child(enemy_instance)
	#projectile_instance.global_transform = global_transform
