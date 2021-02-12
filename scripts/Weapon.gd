extends Spatial

#onready var animation_player = $AnimationPlayer
onready var weapon_manager = get_node("../../")
var bullet_spawners_base : Spatial
var bullet_spawners : Array
var projectile_spawners_base : Spatial
var projectile_spawners : Array

export var automatic_fire = false

var fire_point : Spatial
var collision_bodies_to_ignore : Array = []

export var damage : int = 5
export var ammo = 100
export var max_ammo = 100
export var is_hitscan = true

export var fire_rate = 0.2
var shoot_timer : Timer
var can_shoot = true

var muzzle_flash_timer : Timer
var flash_time : float = 0.1
onready var muzzle_flash_object = get_child(0).get_node("Flash")

signal fired
signal out_of_ammo
signal ammo_changed

#Sounds
onready var soundmanager = get_tree().get_root().get_node("World/NonPositionalSoundManager")

func _ready():
	shoot_timer = Timer.new() #aka ienumerator waitseconds
	shoot_timer.wait_time = fire_rate
	shoot_timer.connect("timeout", self, "finish_attack") #kun shoot_time on ohi niin finish_attack kutsutaan
	add_child(shoot_timer)

	muzzle_flash_timer = Timer.new()
	muzzle_flash_timer.wait_time = flash_time
	muzzle_flash_timer.connect("timeout", self, "hide_muzzle_flash")
	add_child(muzzle_flash_timer)
	
func init(_fire_point: Spatial, _collision_bodies_to_ignore: Array):
	fire_point = _fire_point
	collision_bodies_to_ignore = _collision_bodies_to_ignore

	if is_hitscan:
		bullet_spawners_base = $BulletSpawners
		bullet_spawners = bullet_spawners_base.get_children()
		for bullet_spawner in bullet_spawners:
			bullet_spawner.original_damage = damage
			bullet_spawner.damage = damage
			bullet_spawner.set_bodies_to_exclude(collision_bodies_to_ignore)
	else:
		projectile_spawners_base = $ProjectileSpawners
		projectile_spawners = projectile_spawners_base.get_children()
		for projectile_spawner in projectile_spawners:
			projectile_spawner.damage = damage
			projectile_spawner.original_damage = damage
			projectile_spawner.set_bodies_to_exclude(collision_bodies_to_ignore)

func shoot(shoot_input_just_pressed: bool, shoot_input_held: bool):
	if(!can_shoot):
		return
	if(automatic_fire and !shoot_input_held):
		return
	elif(!automatic_fire and !shoot_input_just_pressed):
		return
	
	if(ammo == 0):
		if(shoot_input_just_pressed):
			emit_signal("out_of_ammo")
		return
	
	if(ammo > 0):
		ammo -= 1
		emit_signal("ammo_changed", ammo)
	
	if is_hitscan:
		var start_transform = bullet_spawners_base.global_transform
		bullet_spawners_base.global_transform = fire_point.global_transform
		for bullet_spawner in bullet_spawners:
			bullet_spawner.set_damage(damage * weapon_manager.powerup_damage_modifier)
			bullet_spawner.fire()
		bullet_spawners_base.global_transform = start_transform
	else:
		shoot_projectile()
	#anim_player.stop()
	#anim_player.play("attack)
	emit_signal("fired")
	can_shoot = false
	shoot_timer.start() #käynnistettään timer jonka jälkeen finish attack tapahtuu
	show_muzzle_flash()

	if self.name == "MachineGun":
		soundmanager.play_sound(0,0)
	elif self.name == "Shotgun":
		soundmanager.play_sound(0,1,1.25)
	elif self.name == "RocketLauncher":
		soundmanager.play_sound(0,2)
	
func finish_attack():
	can_shoot = true
	
func set_active():
	show()
func set_inactive():
	hide()

func show_muzzle_flash():
	#print("SHOW FLASH")
	muzzle_flash_object.show()
	muzzle_flash_timer.start()

func hide_muzzle_flash():
	#print("HIDE FLASH")
	muzzle_flash_object.hide()
	muzzle_flash_timer.stop()

func shoot_projectile():
	#print("DAMAGEMOD: ", weapon_manager.powerup_damage_modifier)
	var start_transform = projectile_spawners_base.global_transform
	projectile_spawners_base.global_transform = fire_point.global_transform
	for projectile_spawner in projectile_spawners:
		projectile_spawner.damage = projectile_spawner.original_damage * weapon_manager.powerup_damage_modifier
		projectile_spawner.explosion_damage = projectile_spawner.original_explosion_damage * weapon_manager.powerup_damage_modifier
		projectile_spawner.fire_projectile()
	projectile_spawners_base.global_transform = start_transform

func add_ammo(pickup : Pickup):
	if ammo < max_ammo:
		if ammo + pickup.amount <= max_ammo:
			ammo += pickup.amount
		else:
			ammo = max_ammo
		print("Weapon: ", name, " ammo amount: ", ammo)
		pickup.queue_free()

		if pickup.pickup_type == pickup.PICKUP_TYPES.AMMO_MACHINE_GUN:
			soundmanager.play_sound(1,0)
		if pickup.pickup_type == pickup.PICKUP_TYPES.AMMO_SHOTGUN:
			soundmanager.play_sound(1,1)
		if pickup.pickup_type == pickup.PICKUP_TYPES.AMMO_ROCKET_LAUNCHER:
			soundmanager.play_sound(1,2)
	
	
	
	
