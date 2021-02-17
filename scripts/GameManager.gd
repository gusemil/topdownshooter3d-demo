extends Node

var control_node
export var is_coop : bool = true
var is_game_over : bool = false
var players = []
onready var solo_scene_prefab = preload("res://scenes/Solo_Scene.tscn")
onready var coop_scene_prefab = preload("res://scenes/Coop_Scene.tscn")
onready var pause_canvas_node = $PauseCanvas/PauseNode

var is_pause : bool = false

signal signal_game_over

func _ready():
	is_coop = GlobalSceneManager.is_coop
	control_node = get_node("../Control")
	if !is_coop:
		setup_solo_play()
	else:
		setup_coop_play()

	players = get_tree().get_nodes_in_group("player")
	for player in players:
		player.connect("player_death", self, "check_if_game_over")

func _input(event):
	if Input.is_action_just_pressed("exit_game"):
		if !is_game_over:
			toggle_pause()
		else:
			quit_game()
	if Input.is_action_just_pressed("restart"):
		restart_game()
func restart_game():
	is_pause = false
	Engine.time_scale = 1
	var children = get_tree().get_root().get_children()
	for child in children:
		child.queue_free()
	get_tree().reload_current_scene()

func exit_game():
	get_tree().quit()

func quit_game():
	Engine.time_scale = 1
	is_pause = false
	get_tree().change_scene("res://scenes/MainMenu.tscn")

func setup_solo_play():
	var scene_instance = solo_scene_prefab.instance()
	control_node.add_child(scene_instance)

func setup_coop_play():
	var scene_instance = coop_scene_prefab.instance()
	control_node.add_child(scene_instance)

func game_over():
	is_game_over = true
	#print("GAME OVER")
	emit_signal("signal_game_over")
	pause_canvas_node.show()
	pause_canvas_node.get_node("PauseLabel").hide()
	pause_canvas_node.get_node("GameOverLabel").show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func check_if_game_over():
	#print("CHECK IF GAME OVER")
	if !is_coop:
		game_over()
	elif players[0].dead and players[1].dead:
			game_over()

func toggle_pause():
	if !is_pause:
		Engine.time_scale = 0
		is_pause = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		pause_canvas_node.show()
	else:
		Engine.time_scale = 1
		is_pause = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		pause_canvas_node.hide()
