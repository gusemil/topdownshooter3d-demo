extends Spatial

onready var animation_player = $AnimationPlayer
onready var bullet_spawners_base : Spatial = $BulletSpawners
onready var bullet_spawners = $BulletSpawners.get_children()

export var automatic_fire = false

var fire_point : Spatial
var collision_bodies_to_ignore : Array = []

export var damage = 5
export var ammo = 100

export var fire_rate = 0.2
var shoot_timer : Timer
var can_shoot = true

signal fired
signal out_of_ammo

func _ready():
	shoot_timer = Timer.new() #aka ienumerator waitseconds
	shoot_timer.wait_time = fire_rate
	shoot_timer.connect("timeout", self, "finish_attack") #kun shoot_time on ohi niin finish_attack kutsutaan
	add_child(shoot_timer)
	
func init(_fire_point: Spatial, _collision_bodies_to_ignore: Array):
	fire_point = _fire_point
	collision_bodies_to_ignore = _collision_bodies_to_ignore
	for bullet_spawner in bullet_spawners:
		bullet_spawner.set_damage(damage)
		bullet_spawner.set_bodies_to_exclude(collision_bodies_to_ignore)

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
	
	var start_transform = bullet_spawners_base.global_transform
	bullet_spawners_base.global_transform = fire_point.global_transform
	for bullet_spawner in bullet_spawners:
		bullet_spawner.fire()
	bullet_spawners_base.global_transform = start_transform
	#anim_player.stop()
	#anim_player.play("attack)
	emit_signal("fired")
	can_shoot = false
	shoot_timer.start() #käynnistettään timer jonka jälkeen finish attack tapahtuu
	
func finish_attack():
	can_shoot = true
	
func set_active():
	show()
	
func set_inactive():
	#anim_player.play("idle")
	hide()
	
	
	
	
	
	
	
	
