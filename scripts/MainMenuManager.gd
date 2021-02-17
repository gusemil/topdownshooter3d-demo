extends Node

onready var how_to_play_button = get_tree().get_root().get_node("MainMenuCanvas/Buttons/HowToPlayButton/HowToPlayImage")
func _ready():
	pass 

func solo_play():
	GlobalSceneManager.is_coop = false
	get_tree().change_scene("res://scenes/World.tscn")

func coop_play():
	GlobalSceneManager.is_coop = true
	get_tree().change_scene("res://scenes/World.tscn")

func how_to_play():
	if !how_to_play_button.is_visible():
		how_to_play_button.show()
	else:
		how_to_play_button.hide()

func exit_game():
	get_tree().quit()
