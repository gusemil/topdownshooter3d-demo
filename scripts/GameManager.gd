extends Node

var control_node
export var is_coop : bool = true
onready var solo_scene_prefab = preload("res://scenes/Solo_Scene.tscn")
onready var coop_scene_prefab = preload("res://scenes/Coop_Scene.tscn")

func _ready():
	control_node = get_node("../Control")
	if !is_coop:
		setup_solo_play()
	else:
		setup_coop_play()

func _input(event):
	if Input.is_action_just_pressed("exit_game"):
		quit_game()
	if Input.is_action_just_pressed("restart"):
		restart_game()

func restart_game():
	var children = get_tree().get_root().get_children()
	for child in children:
		child.queue_free()
	get_tree().reload_current_scene()

func quit_game():
	get_tree().quit()

func setup_solo_play():
	var scene_instance = solo_scene_prefab.instance()
	control_node.add_child(scene_instance)

func setup_coop_play():
	var scene_instance = coop_scene_prefab.instance()
	control_node.add_child(scene_instance)
