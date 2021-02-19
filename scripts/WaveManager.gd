extends Node

var melee_enemy_prefab = preload("res://scenes/Enemy/MeleeEnemy.tscn")
var ranged_enemy_prefab = preload("res://scenes/Enemy/RangedEnemy.tscn")
var melee_boss_prefab = preload("res://scenes/Enemy/MeleeBossEnemy.tscn")
var ranged_boss_prefab = preload("res://scenes/Enemy/RangedBossEnemy.tscn")
var navmesh

enum ENEMIES {MELEE, RANGED, MELEE_BOSS, RANGED_BOSS}

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
const boss_spawn_wave : int = 3


var enemy_prefabs = []

var rng = RandomNumberGenerator.new()
var spawn_timer : Timer
var wave_delay_timer : Timer

var wave_count = 0

var enemy_move_speed_bonus : float = 0
var enemy_projectile_speed_bonus : float = 0
var enemy_attack_rate_bonus : float = 0
var max_enemy_attack_rate : float = 0.75

var has_boss_spawned : bool = false

onready var game_manager = get_tree().get_root().get_node("World/GameManager")

func _ready():
	rng.randomize()
	navmesh = get_tree().get_root().get_node("World/Navigation")
	enemy_prefabs.push_back(melee_enemy_prefab)
	enemy_prefabs.push_back(ranged_enemy_prefab)
	enemy_prefabs.push_back(melee_boss_prefab)
	enemy_prefabs.push_back(ranged_boss_prefab)

	spawn_timer = Timer.new()
	spawn_timer.wait_time = starting_spawn_rate
	spawn_timer.connect("timeout", self, "spawn_enemy")
	add_child(spawn_timer)
	spawn_timer.start()
	spawn_timer.set_one_shot(false)

	wave_delay_timer = Timer.new()
	wave_delay_timer.wait_time = wave_delay_time
	wave_delay_timer.connect("timeout", self, "start_spawning")
	add_child(wave_delay_timer)
	wave_delay_timer.set_one_shot(false)

	game_manager.connect("signal_game_over", self, "stop_spawning")

func spawn_enemy(is_boss : bool = false):
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

		var ranged_choice = rng.randi_range(0,ranged_enemy_chance)
		#print(enemy_choice)
		var enemy_instance

		var boss_integer_mod = 0

		if is_boss:
			boss_integer_mod += 2
			print("BOSS IS TRUE", boss_integer_mod)

		if ranged_choice == ranged_enemy_chance:
			enemy_instance = enemy_prefabs[ENEMIES.RANGED + boss_integer_mod].instance()
			for child in enemy_instance.get_node("AttackArea").get_children():
				child.projectile_speed += enemy_projectile_speed_bonus
		else:
			enemy_instance = enemy_prefabs[ENEMIES.MELEE + boss_integer_mod].instance()

		enemy_instance.move_acceleration += enemy_move_speed_bonus * boss_integer_mod
		enemy_instance.max_speed += enemy_move_speed_bonus * boss_integer_mod
		enemy_instance.attack_rate -= enemy_attack_rate_bonus * boss_integer_mod
		enemy_instance.attack_animation_speed -= (enemy_attack_rate_bonus / 2) * boss_integer_mod

		navmesh.add_child(enemy_instance)
		enemy_instance.global_transform.origin = spawn_point

		enemies_spawned += 1

		var double_spawn_check = rng.randi_range(0, double_spawn_cap)
		if double_spawn_check <= double_spawn_chance:
			spawn_enemy()

		if enemies_spawned >= enemies_per_wave:
			pause_spawning()
		
		print("ENEMIES_SPAWNED: ", enemies_spawned)

func pause_spawning():
	if wave_count > 3 and !has_boss_spawned:
		has_boss_spawned = true
		spawn_enemy(true)
	enemies_spawned = 0
	spawning = false
	spawn_timer.set_paused(true)
	wave_delay_timer.start()
	increase_difficulty()

func stop_spawning():
	spawn_timer.stop()

func start_spawning():
	print("START SPAWNING")
	spawning = true
	has_boss_spawned = false
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
		

