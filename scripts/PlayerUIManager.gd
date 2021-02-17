extends CanvasLayer

onready var death_hud = $DeathHUD
onready var game_over_hud = $GameOverHUD
onready var player = get_node("..")

#Coop
onready var game_manager = get_tree().get_root().get_node("World/GameManager")

func _ready():
	if game_manager.is_coop:
		player.connect("player_death", self, "show_death_hud")
		player.connect("player_resurrect", self, "hide_death_hud")

	game_manager.connect("signal_game_over", self, "show_game_over_hud")

func _process(delta):
	if death_hud.is_visible():
		update_resurrection_time()


func show_death_hud():
	death_hud.show()

func update_resurrection_time():
	death_hud.text = "WAIT FOR RESURRECTION:\n" + round(player.get_resurrection_time()) as String

func hide_death_hud():
	death_hud.hide()

func show_game_over_hud():
	if death_hud.is_visible():
		hide_death_hud()
