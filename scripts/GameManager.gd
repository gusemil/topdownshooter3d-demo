extends Node


func _input(event):
	if Input.is_action_just_pressed("exit_game"):
		quit_game()
	if Input.is_action_just_pressed("restart"):
		restart_game()

func restart_game():
	get_tree().reload_current_scene()

func quit_game():
	get_tree().quit()
