extends Node

const pickup_drop_chance = 3
const powerup_drop_chance = 2
const boss_pickup_drop_chance = 2

var ammo_machinegun_prefab = preload("res://scenes/Pickups/Machinegun_Ammo_Pickup.tscn")
var ammo_shotgun_prefab = preload("res://scenes/Pickups/Shotgun_Ammo_Pickup.tscn")
var ammo_rocketlauncher_prefab = preload("res://scenes/Pickups/RocketLauncher_Ammo_Pickup.tscn")

var health_pickup_prefab = preload("res://scenes/Pickups/Health_Pickup.tscn")
var armor_pickup_prefab = preload("res://scenes/Pickups/Armor_Pickup.tscn")

var powerup_quad_prefab = preload("res://scenes/Pickups/Powerup_Quad_Damage.tscn")
var powerup_undying_prefab = preload("res://scenes/Pickups/Powerup_Undying.tscn")
var powerup_speed_prefab = preload("res://scenes/Pickups/Powerup_Speed_Boost.tscn")

var boss_pickup_prefab = preload("res://scenes/Pickups/Boss_Pickup.tscn")

var rng = RandomNumberGenerator.new()
var pickup_prefabs = []
var powerup_prefabs = []

func _ready():
	rng.randomize()

	pickup_prefabs.push_back(ammo_machinegun_prefab)
	pickup_prefabs.push_back(ammo_shotgun_prefab)
	pickup_prefabs.push_back(ammo_rocketlauncher_prefab)

	pickup_prefabs.push_back(health_pickup_prefab)
	pickup_prefabs.push_back(armor_pickup_prefab)

	powerup_prefabs.push_back(powerup_quad_prefab)
	powerup_prefabs.push_back(powerup_undying_prefab)
	powerup_prefabs.push_back(powerup_speed_prefab)

func drop_pickup(enemy_position : Vector3, is_boss : bool = false):

	if !is_boss:
		var pickup_drop = rng.randi_range(0, pickup_drop_chance)

		if pickup_drop == pickup_drop_chance: #will pickup drop at all
		
			var is_drop_powerup = rng.randi_range(0, powerup_drop_chance)
			
			if is_drop_powerup == powerup_drop_chance: #if drop happens check if powerup
				var powerup_choice = rng.randi_range(0,powerup_prefabs.size() -1)
				
				var powerup_instance = powerup_prefabs[powerup_choice].instance()
				
				get_tree().get_root().add_child(powerup_instance)
				powerup_instance.global_transform.origin = enemy_position + Vector3(0,2.25,0)
			
			else: #else drop a pickup
				var pickup_choice = rng.randi_range(0,pickup_prefabs.size() -1)

				var pickup_instance = pickup_prefabs[pickup_choice].instance()
				
				get_tree().get_root().add_child(pickup_instance)
				pickup_instance.global_transform.origin = enemy_position + Vector3(0,2.25,0)
	else:
		var boss_drop = rng.randi_range(0, boss_pickup_drop_chance)
		if boss_drop == boss_pickup_drop_chance:
			var boss_pickup_instance = boss_pickup_prefab.instance()
			get_tree().get_root().add_child(boss_pickup_instance)
			boss_pickup_instance.global_transform.origin = enemy_position + Vector3(0,2.25,0)

