extends Node

#Sound
onready var gun_player : AudioStreamPlayer = $GunPlayer
onready var pickup_player : AudioStreamPlayer = $PickupPlayer
onready var player_damage_player : AudioStreamPlayer = $PlayerDamagePlayer

var player_arrays = []

var sound_arrays = []

var gun_sounds = []
var pickup_sounds = []
var player_damage_sounds = []

#Guns
onready var gun_sound0 : String = "res://audio/sounds/gun_machinegun_auto_heavy_shot_01.wav"
onready var gun_sound1 : String = "res://audio/sounds/gun_shotgun_shot_02.wav"
onready var gun_sound2 : String = "res://audio/sounds/gun_grenade_launcher_shot_01.wav"

#Pickups
onready var pickup_sound0 : String = "res://audio/sounds/pickup_machinegun.wav"
onready var pickup_sound1 : String = "res://audio/sounds/pickup_shotgun.wav"
onready var pickup_sound2 : String = "res://audio/sounds/pickup_rocketlauncher.wav"
onready var pickup_sound3 : String = "res://audio/sounds/Health.wav"
onready var pickup_sound4 : String = "res://audio/sounds/Armor.wav"
onready var pickup_sound5 : String = "res://audio/sounds/Quad_On.wav"
onready var pickup_sound6 : String = "res://audio/sounds/UndyingOn.wav"
onready var pickup_sound7 : String = "res://audio/sounds/DashOn.wav"
onready var pickup_sound8 : String = "res://audio/sounds/Quad_Off.wav"
onready var pickup_sound9 : String = "res://audio/sounds/UndyingOff.wav"
onready var pickup_sound10 : String = "res://audio/sounds/DashOff.wav"
onready var pickup_sound11 : String = "res://audio/sounds/BossPickup.wav"

#Player Damage sounds
onready var player_damage_sound0 : String = "res://audio/sounds/player_damage.wav"
onready var player_damage_sound1 : String = "res://audio/sounds/player_armor_damage.wav"
onready var player_damage_sound2 : String = "res://audio/sounds/player_deflect.wav"

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	
	player_arrays.push_back(gun_player)
	player_arrays.push_back(pickup_player)
	player_arrays.push_back(player_damage_player)
	
	gun_sounds.push_back(gun_sound0)
	gun_sounds.push_back(gun_sound1)
	gun_sounds.push_back(gun_sound2)
	
	pickup_sounds.push_back(pickup_sound0)
	pickup_sounds.push_back(pickup_sound1)
	pickup_sounds.push_back(pickup_sound2)
	pickup_sounds.push_back(pickup_sound3)
	pickup_sounds.push_back(pickup_sound4)
	pickup_sounds.push_back(pickup_sound5)
	pickup_sounds.push_back(pickup_sound6)
	pickup_sounds.push_back(pickup_sound7)
	pickup_sounds.push_back(pickup_sound8)
	pickup_sounds.push_back(pickup_sound9)
	pickup_sounds.push_back(pickup_sound10)
	pickup_sounds.push_back(pickup_sound11)
	
	player_damage_sounds.push_back(player_damage_sound0)
	player_damage_sounds.push_back(player_damage_sound1)
	player_damage_sounds.push_back(player_damage_sound2)

	sound_arrays.push_back(gun_sounds)
	sound_arrays.push_back(pickup_sounds)
	sound_arrays.push_back(player_damage_sounds)
	
func play_sound(array_index, sound_index : int, pitch_scale = 1.0):
	player_arrays[array_index].stream = load(sound_arrays[array_index][sound_index])
	player_arrays[array_index].pitch_scale = pitch_scale
	player_arrays[array_index].play()
