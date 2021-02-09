extends Node

#Music
onready var music_manager_player : AudioStreamPlayer = $AudioStreamPlayer
var music_tracks = []
onready var track0 : String = "res://audio/music/GetOut.wav"
onready var track1 : String = "res://audio/music/KneeDeepintheDead.wav"
onready var track2 : String = "res://audio/music/BFG.wav"
onready var track3 : String = "res://audio/music/CosmicDeathMachine.wav"
onready var track4 : String = "res://audio/music/FightLikeHell.wav"
onready var track5 : String = "res://audio/music/MarkOfTheDoomSlayer.wav"
onready var track6 : String = "res://audio/music/TornFlesh.wav"
onready var track7 : String = "res://audio/music/DoomedToSurvive.wav"


var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize() #aka seeding
	music_tracks.push_back(track0)
	music_tracks.push_back(track1)
	music_tracks.push_back(track2)
	music_tracks.push_back(track3)
	music_tracks.push_back(track4)
	music_tracks.push_back(track5)
	music_tracks.push_back(track6)
	music_tracks.push_back(track7)
	play_music_shuffle()

func play_music_shuffle():
	var random_index = rng.randi_range(0, music_tracks.size() -1)
	music_manager_player.stream = load(music_tracks[random_index])
	music_manager_player.play()
	yield(music_manager_player, "finished") #start a new track after current one finishes
	play_music_shuffle()
