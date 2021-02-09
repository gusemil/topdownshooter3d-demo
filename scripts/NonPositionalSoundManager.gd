extends Node

#Sound
onready var sound_manager = $SoundManager
onready var non_positional_soundmanager_player : AudioStreamPlayer = $AudioStreamPlayer

var sounds = []
onready var sound0 : String = "res://audio/sounds/gun_shotgun_shot_01.wav"

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	sounds.push_back(sound0)

func play_sound(index : int):
	non_positional_soundmanager_player.stream = load(sounds[index])
	non_positional_soundmanager_player.play()
