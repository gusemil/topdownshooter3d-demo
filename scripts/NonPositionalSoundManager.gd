extends Node

#Sound
onready var non_positional_soundmanager_player : AudioStreamPlayer = $GunPlayer

var sound_arrays = []
var gun_sounds = []
var pickup_sounds = []

#Guns
onready var gun_sound0 : String = "res://audio/sounds/gun_machinegun_auto_heavy_shot_01.wav"
onready var gun_sound1 : String = "res://audio/sounds/gun_shotgun_shot_02.wav"
onready var gun_sound2 : String = "res://audio/sounds/gun_tank_cannon_turret_shot_01.wav"

#Pickups
onready var pickup_sound0 : String = "res://audio/sounds/pickup_machinegun.wav"
onready var pickup_sound1 : String = "res://audio/sounds/pickup_shotgun.wav"
onready var pickup_sound2 : String = "res://audio/sounds/pickup_rocketlauncher.wav"

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	gun_sounds.push_back(gun_sound0)
	gun_sounds.push_back(gun_sound1)
	gun_sounds.push_back(gun_sound2)
	
	pickup_sounds.push_back(pickup_sound0)
	pickup_sounds.push_back(pickup_sound1)
	pickup_sounds.push_back(pickup_sound2)

	sound_arrays.push_back(gun_sounds)
	sound_arrays.push_back(pickup_sounds)

func play_sound(array_index, sound_index : int, pitch_scale = 1.0):
	non_positional_soundmanager_player.stream = load(sound_arrays[array_index][sound_index])
	non_positional_soundmanager_player.pitch_scale = pitch_scale
	non_positional_soundmanager_player.play()
