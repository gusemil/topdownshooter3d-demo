extends Node

var melee_enemy_prefab = preload("res://scenes/Enemy/MeleeEnemy.tscn")
var ranged_enemy_prefab = preload("res://scenes/Enemy/RangedEnemy.tscn")
var navmesh

enum ENEMIES {MELEE, RANGED}

export var ranged_enemy_chance = 4
export var starting_spawn_rate : float = 2.5
export var spawning : bool = true
var enemies_per_wave : int = 10
var enemies_spawned : int = 0
var wave_delay_time : float = 5
var spawn_rate_reduction_per_wave : float = 0.25
var double_spawn_chance : int = 1

const min_spawn_rate : float = 0.25
const max_double_spawn_chance : int = 10
const double_spawn_cap : int = 20


var enemy_prefabs = []

var rng = RandomNumberGenerator.new()
var spawn_timer : Timer
var wave_delay_timer : Timer

var wave_count = 0

var enemy_move_speed_bonus : float = 0
var enemy_projectile_speed_bonus : float = 0
var enemy_attack_rate_bonus : float = 0
var max_enemy_attack_rate : float = 0.75

func _ready():
	rng.randomize()
	navmesh = get_tree().get_root().get_node("World/Navigation")
	enemy_prefabs.push_back(melee_enemy_prefab)
	enemy_prefabs.push_back(ranged_enemy_prefab)

	spawn_timer = Timer.new()
	spawn_timer.wait_time = starting_spawn_rate
	spawn_timer.connect("timeout", self, "spawn_random_normal_enemy")
	add_child(spawn_timer)
	spawn_timer.start()
	spawn_timer.set_one_shot(false)

	wave_delay_timer = Timer.new()
	wave_delay_timer.wait_time = wave_delay_time
	wave_delay_timer.connect("timeout", self, "start_spawning")
	add_child(wave_delay_timer)
	wave_delay_timer.set_one_shot(false)

func spawn_random_normal_enemy():
	if spawning:
		var direction = rng.randi_range(0,3)
		var spawn_point : Vector3

		#print("DIRECTION: ", direction)
		if(direction == 0):
			spawn_point = Vector3(rng.randi_range(-47,47),0,rng.randi_range(-47,-40))
		elif(direction == 1):
			spawn_point = Vector3(rng.randi_range(-47,-40),0,rng.randi_range(-47,47))
		elif(direction == 2):
			spawn_point = Vector3(rng.randi_range(-47,47),0,rng.randi_range(40,47))
		elif(direction == 3):
			spawn_point = Vector3(rng.randi_range(40,47),0,rng.randi_range(-47,47))

		var enemy_choice = rng.randi_range(0,ranged_enemy_chance)
		#print(enemy_choice)
		var enemy_instance
		if enemy_choice == ranged_enemy_chance:
			enemy_instance = enemy_prefabs[1].instance()
			enemy_instance.get_node("AttackArea/ProjectileSpawner").projectile_speed += enemy_projectile_speed_bonus
		else:
			enemy_instance = enemy_prefabs[0].instance()

		enemy_instance.move_acceleration += enemy_move_speed_bonus
		enemy_instance.max_speed += enemy_move_speed_bonus
		enemy_instance.attack_rate -= enemy_attack_rate_bonus

		navmesh.add_child(enemy_instance)
		enemy_instance.global_transform.origin = spawn_point

		enemies_spawned += 1

		var double_spawn_check = rng.randi_range(0, double_spawn_cap)
		if double_spawn_check <= double_spawn_chance:
			print("DOUBLE SPAWN")
			spawn_random_normal_enemy()

		if enemies_spawned >= enemies_per_wave:
			enemies_spawned = 0
			pause_spawning()
		
		print("ENEMIES_SPAWNED: ", enemies_spawned)

func pause_spawning():
	spawning = false
	spawn_timer.set_paused(true)
	wave_delay_timer.start()
	increase_difficulty()

func start_spawning():
	print("START SPAWNING")
	spawning = true
	spawn_timer.set_paused(false)
	wave_delay_timer.stop()

func increase_difficulty():
	enemies_per_wave += 10
	wave_delay_time += 0.5
	wave_count += 1
	enemy_move_speed_bonus += 2
	enemy_projectile_speed_bonus += 1
	
	if spawn_timer.wait_time > min_spawn_rate:
		spawn_timer.wait_time -= spawn_rate_reduction_per_wave
	else:
		if enemy_attack_rate_bonus < max_enemy_attack_rate:
			enemy_attack_rate_bonus += 0.05

		if double_spawn_chance < max_double_spawn_chance:
			double_spawn_chance += 1
		

