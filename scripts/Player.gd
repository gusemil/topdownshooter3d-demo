extends KinematicBody

# Movement essentials
export var speed = 300
export var friction = 0.875
export var gravity = 80
export var camera_rotation_speed = 250
var move_direction = Vector3()
var velocity = Vector3()

# Camera
onready var camera = $CameraRig/Camera
onready var camera_rig = $CameraRig
onready var cursor= $Cursor

# Addons
onready var weapon_manager = $WeaponManager
onready var health_manager = $HealthManager

# Dash
export var dash_speed : float = 30
var is_dashing = false

# State
var dead = false

#Speed Boost Powerup
var default_speed = speed
var default_dash_speed = dash_speed
var is_speed_boost_on : bool = false
var speed_boost_timer : Timer
var is_speed_powerup_initialized : bool = false

#Undying powerup
var is_invulnerability_on : bool = false
var invulnerability_timer : Timer
var is_undying_powerup_initialized : bool = false
onready var undying_powerup_effect = $Graphics/UndyingPowerUpEffect

#Animation
onready var animation_player = $Graphics/Armature/AnimationPlayer

#Sounds
onready var soundmanager = get_tree().get_root().get_node("World/NonPositionalSoundManager")



func _ready():
	camera_rig.set_as_toplevel(true)
	cursor.set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	weapon_manager.init($WeaponManager/FirePoint, [self]) #exclude player from bullet collisions
	health_manager.connect("dead", self, "death") #Kun healthmanagerin dead emitataan niin pelaajan death funktio aktivoituu
	health_manager.connect("armor_damage", self, "play_armor_damage_sound")
	health_manager.connect("health_damage", self, "play_health_damage_sound")

		
func _process(_delta):
	weapon_manager.shoot(Input.is_action_just_pressed("shoot"), Input.is_action_pressed("shoot"))


func _physics_process(delta):
	camera_follows_player()
	look_at_cursor()
	move(delta)
	animate_move()
	
	velocity *= friction
	velocity.y -= gravity*delta
	velocity = move_and_slide(velocity, Vector3.UP, true, 3)

func camera_follows_player():
	var player_pos = global_transform.origin
	camera_rig.global_transform.origin = player_pos

func look_at_cursor():
	if !dead:
		# Create a horizontal plane, and find a point where the ray intersects with it
		var player_pos = global_transform.origin
		var dropPlane  = Plane(Vector3(0, 1, 0), player_pos.y)
		# Project a ray from camera, from where the mouse cursor is in 2D viewport
		var ray_length = 1000
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var cursor_pos = dropPlane.intersects_ray(from,to)
		
		# Set the position of cursor visualizer
		cursor.global_transform.origin = cursor_pos + Vector3(0,1,0)
		
		# Make player look at the cursor
		look_at(cursor_pos, Vector3.UP)


func move(delta):
	if !dead:
		move_direction = Vector3()
		var camera_basis = camera.get_global_transform().basis
		if Input.is_action_pressed("move_forward"):
			move_direction -= camera_basis.z
			#animation_player.play("RunForward-loop")
		elif Input.is_action_pressed("move_backward"):
			move_direction += camera_basis.z
			#animation_player.play("RunBackward-loop")
		if Input.is_action_pressed("move_left"):
			move_direction -= camera_basis.x
			#animation_player.play("RunLeft-loop")
		elif Input.is_action_pressed("move_right"):
			move_direction += camera_basis.x
			#animation_player.play("RunRight-loop")
		move_direction.y = 0
		move_direction = move_direction.normalized()
		if Input.is_action_just_pressed("dash"):
			velocity += move_direction*speed*delta*dash_speed
		else:
			velocity += move_direction*speed*delta

	#else:
	#	animation_player.play("CombatIdle-loop")

func animate_move():
	if !dead:
		if !Input.is_action_pressed("move_forward") or !Input.is_action_pressed("move_backward") or !Input.is_action_pressed("move_left") or !Input.is_action_pressed("move_right") or !Input.is_action_pressed("dash"):
			if Input.is_action_pressed("move_forward"):
				animation_player.play("RunForward-loop")
			elif Input.is_action_pressed("move_backward"):
				animation_player.play("RunBackward-loop")
			elif Input.is_action_pressed("move_left"):
				animation_player.play("RunLeft-loop")
			elif Input.is_action_pressed("move_right"):
				animation_player.play("RunRight-loop")
			elif Input.is_action_just_pressed("dash"):
				pass
			else:
				animation_player.play("AimFireRifle")

func take_damage(dmg : int):
	if !is_invulnerability_on:
		health_manager.take_damage(dmg)
	else:
		play_invulnerability_sound()
		print("I AM INVULNERABLE!")

func death():
	dead = true
	#print("Player is dead")

func init_speed_powerup(powerup : Powerup):
	if !is_speed_powerup_initialized:
		speed_boost_timer = Timer.new()
		speed_boost_timer.wait_time = powerup.length
		speed_boost_timer.connect("timeout", self, "stop_speed_boost")
		add_child(speed_boost_timer)
		is_speed_powerup_initialized = true
func apply_speed_boost(powerup : Powerup):
	if !is_speed_boost_on:
		speed *= 2
		dash_speed *= 1.25
		is_speed_boost_on = true
		speed_boost_timer.start()
		soundmanager.play_sound(1,7)
		powerup.queue_free()

func stop_speed_boost():
	is_speed_boost_on = false
	speed = default_speed
	dash_speed = default_dash_speed
	speed_boost_timer.stop()
	soundmanager.play_sound(1,10)
	print("STOP SPEED")

func apply_invulnerability(powerup : Powerup):
	if !is_invulnerability_on:
		is_invulnerability_on = true
		invulnerability_timer.start()
		soundmanager.play_sound(1,6)
		powerup.queue_free()
		undying_powerup_effect.show()

func stop_invulnerability():
	is_invulnerability_on = false
	invulnerability_timer.stop()
	soundmanager.play_sound(1,9)
	undying_powerup_effect.hide()
	print("STOP INVUL")

func init_undying_powerup(powerup : Powerup):
	if !is_undying_powerup_initialized:
		invulnerability_timer = Timer.new()
		invulnerability_timer.wait_time = powerup.length
		invulnerability_timer.connect("timeout", self, "stop_invulnerability")
		add_child(invulnerability_timer)
		is_undying_powerup_initialized = true

func play_armor_damage_sound():
	soundmanager.play_sound(2,1)

func play_health_damage_sound():
	soundmanager.play_sound(2,0)

func play_invulnerability_sound():
	soundmanager.play_sound(2,2)
