extends Node

var melee_enemy_prefab = preload("res://scenes/MeleeEnemy.tscn")
var ranged_enemy_prefab = preload("res://scenes/RangedEnemy.tscn")
var navmesh

enum ENEMIES {MELEE, RANGED}

export var ranged_enemy_chance = 4
export var spawn_rate : float = 2.5
#var spawns_per_wave : int = 1
#var enemies_per_spawn : int = 1


var enemy_prefabs = []

var rng = RandomNumberGenerator.new()
var spawn_timer : Timer

func _ready():
	rng.randomize()
	navmesh = get_tree().get_root().get_node("World/Navigation")
	enemy_prefabs.push_back(melee_enemy_prefab)
	enemy_prefabs.push_back(ranged_enemy_prefab)

	spawn_timer = Timer.new() #aka ienumerator waitseconds
	spawn_timer.wait_time = spawn_rate
	spawn_timer.connect("timeout", self, "spawn_random_normal_enemy")
	add_child(spawn_timer)
	spawn_timer.start()
	spawn_timer.set_one_shot(false)

func spawn_random_normal_enemy():
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

	var enemy_choice = rng.randi_range(0,ranged_enemy_chance)
	print(enemy_choice)
	var enemy_instance
	if enemy_choice == ranged_enemy_chance:
		enemy_instance = enemy_prefabs[1].instance()
	else:
		enemy_instance = enemy_prefabs[0].instance()

	navmesh.add_child(enemy_instance)
	enemy_instance.global_transform.origin = spawn_point
