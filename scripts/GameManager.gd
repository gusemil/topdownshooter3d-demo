extends Node

var control_node
export var is_coop : bool = true
var is_game_over : bool = false
var players = []
var score : int = 0
var play_time_scale = 1
onready var solo_scene_prefab = preload("res://scenes/Solo_Scene.tscn")
onready var coop_scene_prefab = preload("res://scenes/Coop_Scene.tscn")
onready var pause_canvas_node = $PauseCanvas/PauseNode
onready var score_canvas = $PlayCanvas
onready var score_hud = score_canvas.get_node("ScoreLabel")
onready var wave_hud = score_canvas.get_node("WaveLabel")
onready var sound_manager = get_tree().get_root().get_node("World/NonPositionalSoundManager")
onready var wave_manager = get_tree().get_root().get_node("World/WaveManager")

var is_pause : bool = false

signal signal_game_over

#Bullet time powerup
const bullet_time_scale_value : float = 0.5
var is_bullet_time_on : bool = false
var bullet_time_timer : Timer
var is_bullet_time_powerup_initialized : bool = false

func _ready():
	if GlobalSceneManager != null:
		is_coop = GlobalSceneManager.is_coop
	else:
		is_coop = self.is_coop

	control_node = get_node("../Control")
	if !is_coop:
		setup_solo_play()
	else:
		setup_coop_play()

	players = get_tree().get_nodes_in_group("player")
	for player in players:
		player.connect("player_death", self, "check_if_game_over")

	wave_manager.connect("wave_count_changed", self, "update_wave_text")

	add_score(0)
	update_wave_text()

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
	remove_all_objects()
	var temp_is_coop = is_coop
	get_tree().reload_current_scene()

func exit_game():
	get_tree().quit()

func quit_game():
	Engine.time_scale = 1
	is_pause = false
	remove_all_objects()
	get_tree().change_scene("res://scenes/MainMenu.tscn")

func setup_solo_play():
	var scene_instance = solo_scene_prefab.instance()
	control_node.add_child(scene_instance)

func setup_coop_play():
	var scene_instance = coop_scene_prefab.instance()
	control_node.add_child(scene_instance)

func game_over():
	is_game_over = true
	emit_signal("signal_game_over")
	pause_canvas_node.show()
	pause_canvas_node.get_node("PauseLabel").hide()
	pause_canvas_node.get_node("GameOverLabel").show()
	score_hud.hide()
	pause_canvas_node.get_node("GameOverLabel/ScoreLabelFinal").text = "Final Score: " + score as String
	pause_canvas_node.get_node("Buttons/ContinueButton").hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func add_score(amount : int):
	score += amount
	score_hud.text = "Score: " + score as String
	emit_signal("score_changed")

func update_wave_text():
	wave_hud.text = "Wave Count: " + (wave_manager.wave_count +1) as String

func check_if_game_over():
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
		Engine.time_scale = play_time_scale
		is_pause = false
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		pause_canvas_node.hide()

func apply_bullet_time(powerup : Powerup):
	if !is_bullet_time_on:
		is_bullet_time_on = true
		play_time_scale = bullet_time_scale_value
		Engine.time_scale = bullet_time_scale_value
		bullet_time_timer.start()
		sound_manager.play_sound(1,13)
		powerup.queue_free()

func init_bullet_time_powerup(powerup : Powerup):
	if !is_bullet_time_powerup_initialized:
		bullet_time_timer = Timer.new()
		bullet_time_timer.wait_time = powerup.length
		bullet_time_timer.connect("timeout", self, "stop_bullet_time")
		add_child(bullet_time_timer)
		is_bullet_time_powerup_initialized = true

func stop_bullet_time():
	is_bullet_time_on = false
	play_time_scale = 1.0
	Engine.time_scale = 1.0
	bullet_time_timer.stop()
	sound_manager.play_sound(1,14)

func remove_all_objects():
	var children = get_tree().get_root().get_children()
	for child in children:
		if child.name != "GlobalSceneManager":
			child.queue_free()
