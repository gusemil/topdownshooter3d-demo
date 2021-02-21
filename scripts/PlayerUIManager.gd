extends CanvasLayer

onready var death_hud = $DeathHUD
onready var game_over_hud = $GameOverHUD
onready var pickup_hud = $PickupHUD
onready var pickup_timer = $PickupTimer
onready var ammo_hud = $AmmoHUD
onready var ammo_timer = $AmmoTimer

onready var player = get_node("..")

#Coop
onready var game_manager = get_tree().get_root().get_node("World/GameManager")

func _ready():
	if game_manager.is_coop:
		player.connect("player_death", self, "show_death_hud")
		player.connect("player_resurrect", self, "hide_death_hud")

	game_manager.connect("signal_game_over", self, "show_game_over_hud")
	pickup_timer.connect("timeout", self, "hide_pickup_hud")
	ammo_timer.connect("timeout", self, "hide_ammo_hud")

func _process(delta):
	if death_hud.is_visible():
		update_resurrection_time()

func show_death_hud():
	death_hud.show()

func show_pickup_hud(pickup_text : String):
	pickup_hud.show()
	pickup_hud.text = pickup_text
	pickup_timer.start()

func hide_pickup_hud():
	pickup_hud.hide()

func show_ammo_hud(ammo_text : String):
	ammo_hud.show()
	ammo_hud.text = "Picked Up: " + ammo_text
	ammo_timer.start()

func hide_ammo_hud():
	ammo_hud.hide()

func update_resurrection_time():
	death_hud.text = "WAIT FOR RESURRECTION:\n" + round(player.get_resurrection_time()) as String

func hide_death_hud():
	death_hud.hide()

func show_game_over_hud():
	if death_hud.is_visible():
		hide_death_hud()
