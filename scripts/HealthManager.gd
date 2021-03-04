extends Spatial

export var is_player : bool = false
export var max_health : int = 100
onready var current_health : int = max_health
export var max_armor : int = 100
export var starting_armor : int = 0
onready var current_armor : int = starting_armor

onready var player_canvas = get_node("../CanvasLayer")

signal dead
signal take_damage
signal health_changed
signal armor_changed
signal health_damage
signal armor_damage

var blood_spray_prefab = preload("res://scenes/BloodSpray.tscn")
onready var armor_sparks_prefab = preload("res://scenes/BulletHitEffect.tscn")
onready var bomb_effect_prefab = preload("res://scenes/BombEffect.tscn")

#Sounds
onready var soundmanager = get_tree().get_root().get_node("World/NonPositionalSoundManager")

onready var game_manager = get_tree().get_root().get_node("World/GameManager")

func _ready():
	emit_signal("health_changed", current_health)
	emit_signal("armor_changed", current_armor)
	if is_player:
		game_manager.connect("signal_game_over", self, "player_death_blood")

func take_damage(dmg : int):
	if current_armor > 0:
		var armor_before_dmg = current_armor
		current_armor -= dmg
		dmg -= armor_before_dmg
		if current_armor < 0:
			current_armor = 0
		emit_signal("armor_damage")
		spawn_particles(armor_sparks_prefab,dmg, Vector3(0,2,0))
		emit_signal("armor_changed", current_armor)

	if current_armor <= 0 and dmg > 0:
		current_health -= dmg
		emit_signal("health_damage")

		if current_health <= 0:
			emit_signal("dead")
		else:
			emit_signal("take_damage")

		emit_signal("health_changed", current_health)
		spawn_particles(blood_spray_prefab,dmg, Vector3(0,2,0))

func bomb_effect():
	spawn_particles(bomb_effect_prefab, 250, Vector3(0,2,0))

func spawn_particles(prefab, dmg : int, offset : Vector3, amount_modifier = 2, looping : bool = false):
	var prefab_instance = prefab.instance()
	var particles = prefab_instance.get_child(0)
	if looping:
		particles.one_shot = false
		particles.emitting = true
		if prefab_instance.has_method("infinite_loop"):
			prefab_instance.infinite_loop()
	particles.set_amount(dmg * amount_modifier)
	get_tree().get_root().add_child(prefab_instance)
	prefab_instance.global_transform.origin = global_transform.origin + offset

func gain_health(pickup : Pickup):
	if current_health < max_health:
		if current_health + pickup.amount <= max_health:
			current_health += pickup.amount
		else:
			current_health = max_health
		soundmanager.play_sound(1,3)
		player_canvas.show_ammo_hud("HEALTH")
		emit_signal("health_changed", current_health)
		pickup.queue_free()

func gain_armor(pickup : Pickup):
	if current_armor < max_armor:
		if current_armor + pickup.amount <= max_armor:
			current_armor += pickup.amount
		else:
			current_armor = max_armor
		soundmanager.play_sound(1,4)
		player_canvas.show_ammo_hud("ARMOR")
		emit_signal("armor_changed", current_armor)
		pickup.queue_free()

func set_health_forced(amount):
	current_health = amount
	emit_signal("health_changed", current_health)
		
func player_death_blood():
		spawn_particles(blood_spray_prefab,50, Vector3(0,0,0), 2, true)
