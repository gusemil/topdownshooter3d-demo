extends Node

#Sound
onready var sound_manager = $SoundManager

#Music
onready var music_manager = $MusicManager
onready var music_manager_player : AudioStreamPlayer = $MusicManager/AudioStreamPlayer
var music_tracks = []
onready var track1 : String = "res://audio/music/GetOut.wav"
onready var track2 : String = "res://audio/music/KneeDeepintheDead.wav"

func _ready():
	music_tracks.push_back(track1)
	music_tracks.push_back(track2)
	play_music(1)
	
func play_music(index : int):
	music_manager_player.stream = load(music_tracks[index])
	music_manager_player.play()
