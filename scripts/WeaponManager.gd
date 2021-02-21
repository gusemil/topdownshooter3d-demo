extends Spatial

#Essentials
enum WEAPON_SLOTS {MACHINE_GUN, SHOTGUN, ROCKET_LAUNCHER}
onready var weapons = $Weapons.get_children()
var current_slot = 0
var current_weapon = null
var fire_point : Spatial
var collision_bodies_to_ignore : Array = []

#Bombs
var bombs : int = 0
var max_bombs : int = 3

#Signals
signal ammo_changed
signal weapon_changed
signal bombs_changed

#Quad damage
onready var quad_powerup_effect : Particles = $QuadPowerUpEffect
var powerup_damage_modifier : int = 1
var is_quad_damage_on : bool = false
var quad_damage_timer : Timer
var is_quad_powerup_initialized : bool = false

#Sounds
onready var sound_manager = get_tree().get_root().get_node("World/NonPositionalSoundManager")

#2player support
onready var player = get_node("..")
var player_number : String = ""
var is_player_dead : bool = false

func _process(delta):
	if Input.is_action_just_pressed("weapon1" + player_number) and current_slot != WEAPON_SLOTS.MACHINE_GUN:
		change_weapon(WEAPON_SLOTS.MACHINE_GUN)
	elif Input.is_action_just_pressed("weapon2" + player_number) and current_slot != WEAPON_SLOTS.SHOTGUN:
		change_weapon(WEAPON_SLOTS.SHOTGUN)
	elif Input.is_action_just_pressed("weapon3" + player_number) and current_slot != WEAPON_SLOTS.ROCKET_LAUNCHER:
		change_weapon(WEAPON_SLOTS.ROCKET_LAUNCHER)

	if Input.is_action_just_released("bomb1") and bombs > 0:
		activate_bomb()


func init(_fire_point: Spatial, _collision_bodies_to_ignore: Array):
	fire_point = _fire_point
	collision_bodies_to_ignore = _collision_bodies_to_ignore
	current_weapon = weapons[0]
	current_slot = 0
	current_weapon.set_active()

	print($Weapons.get_child_count())
	print(current_weapon)
	
	current_weapon = weapons[current_slot]
	
	player_number = player.player_number
	
	for weapon in weapons:
		if weapon.has_method("init"):
			weapon.init(_fire_point, [_collision_bodies_to_ignore])

	emit_signal("ammo_changed", weapons[WEAPON_SLOTS.MACHINE_GUN].ammo)
	emit_signal("weapon_changed", weapons[WEAPON_SLOTS.MACHINE_GUN].max_ammo)

	player.connect("player_death", self, "toggle_player_dead")
	player.connect("player_resurrect", self, "toggle_player_dead")

func shoot(attack_input_just_pressed: bool, attack_input_held: bool):
	if current_weapon.has_method("shoot"):
		current_weapon.shoot(attack_input_just_pressed, attack_input_held)

func change_weapon(new_weapon_index : int):
	if !is_player_dead:
		#if new_weapon_index != current_slot:
		#print("Current weapon: ", current_slot, " new weapon: ", new_weapon_index)
		current_weapon.set_inactive()
		current_slot = new_weapon_index
		current_weapon = weapons[current_slot]
		current_weapon.set_active()
		emit_signal("ammo_changed", weapons[current_slot].ammo)
		emit_signal("weapon_changed", weapons[current_slot].max_ammo)

func add_ammo(pickup : Pickup):
	weapons[pickup.pickup_type].add_ammo(pickup.amount, pickup)
	emit_signal("ammo_changed", weapons[pickup.pickup_type].ammo)

func add_bomb(pickup : Pickup):
	if bombs + pickup.amount <= max_bombs:
		bombs += 1
		print("BOMB AMOUNT: ", bombs)
		sound_manager.play_sound(1,12)
		pickup.queue_free()
		player.get_node("CanvasLayer").show_ammo_hud("Bomb")
		emit_signal("bombs_changed", bombs)

func add_ammo_boss(weapon_index : int, amount : int):
	weapons[weapon_index].add_ammo(amount)
	emit_signal("ammo_changed", weapons[current_slot].ammo)

func get_powerup_damage_mod():
	return powerup_damage_modifier

func init_quad_powerup(powerup : Powerup):
	if !is_quad_powerup_initialized:
		quad_damage_timer = Timer.new()
		quad_damage_timer.wait_time = powerup.length
		quad_damage_timer.connect("timeout", self, "stop_quad_damage")
		add_child(quad_damage_timer)
		is_quad_powerup_initialized = true

func apply_quad_damage(powerup : Powerup):
	if !is_quad_damage_on:
		is_quad_damage_on = true
		powerup_damage_modifier = 4
		quad_damage_timer.start()
		sound_manager.play_sound(1,5)
		quad_powerup_effect.emitting = true
		player.get_node("CanvasLayer").show_pickup_hud("QUAD DAMAGE")
		powerup.queue_free()

func stop_quad_damage():
	quad_damage_timer.stop()
	is_quad_damage_on = false
	powerup_damage_modifier = 1
	sound_manager.play_sound(1,8)
	quad_powerup_effect.emitting = false

func toggle_player_death():
	if !is_player_dead:
		is_player_dead = true
	else:
		is_player_dead = false

func activate_bomb():
	print("ACTIVATe BOMB!", bombs)
	bombs -= 1
	var enemies = get_tree().get_nodes_in_group("enemy")
	for enemy in enemies:
		if !enemy.is_dead:
			enemy.queue_free()
			enemy.get_node("HealthManager").bomb_effect()

	emit_signal("bombs_changed", bombs)
	sound_manager.play_sound(3,0)

	player.get_node("HealthManager").bomb_effect()
