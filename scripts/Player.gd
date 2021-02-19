extends KinematicBody

#Movement essentials
export var speed = 300
export var friction = 0.875
export var gravity = 80
#export var camera_rotation_speed = 250
var move_direction = Vector3()
var velocity = Vector3()

#Camera
onready var camera = $CameraRig/Camera
onready var camera_rig = $CameraRig
onready var cursor= $Cursor

#Child nodes
onready var weapon_manager = $WeaponManager
onready var health_manager = $HealthManager

# Dash
export var dash_speed : float = 30
var is_dashing = false
var dash_timer : Timer
const starting_dash_rate : float = 0.5
var can_dash : bool = true

#State
var dead : bool = false
signal player_death
var game_over : bool = false

#Speed Boost Powerup
var default_speed = speed
var default_dash_speed = dash_speed
var is_speed_boost_on : bool = false
var speed_boost_timer : Timer
var is_speed_powerup_initialized : bool = false

onready var speed_powerup_effect : Particles = $SpeedPowerUpEffect

#Undying powerup
var is_invulnerability_on : bool = false
var invulnerability_timer : Timer
var is_undying_powerup_initialized : bool = false
onready var undying_powerup_effect = $Graphics/UndyingPowerUpEffect

#Animation
onready var animation_player = $Graphics/Armature/AnimationPlayer

#Sounds
onready var soundmanager = get_tree().get_root().get_node("World/NonPositionalSoundManager")

#Controller
export var is_controller : bool = false
#onready var controller_cursor = $Controller_Cursor
export var rotation_speed = 600
#export var cursor_gravity = 80
#export var camera_rotation_speed = 250
var cursor_move_direction = Vector3()
var cursor_velocity = Vector3()

#UI
onready var death_hud = $CanvasLayer/DeathHUD
onready var game_over_hud = $CanvasLayer/GameOverHUD

#2player support
export var player_number : String = "1"
onready var game_manager = get_tree().get_root().get_node("World/GameManager")
var is_coop : bool = false
signal player_resurrect
var resurrection_timer : Timer
var resurrection_wait_time = 5.0



func _ready():
	camera_rig.set_as_toplevel(true)
	if is_controller:
		cursor.hide()
	else:
		cursor.set_as_toplevel(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	weapon_manager.init($WeaponManager/FirePoint, [self]) #exclude player from bullet collisions
	health_manager.connect("dead", self, "death") #Kun healthmanagerin dead emitataan niin pelaajan death funktio aktivoituu
	health_manager.connect("armor_damage", self, "play_armor_damage_sound")
	health_manager.connect("health_damage", self, "play_health_damage_sound")

	dash_timer = Timer.new()
	dash_timer.wait_time = starting_dash_rate
	dash_timer.connect("timeout", self, "stop_dash_delay")
	add_child(dash_timer)
	dash_timer.set_one_shot(false)

	if game_manager.is_coop:
		is_coop = true
		game_manager.connect("signal_game_over", self, "stop_resurrection_timer")

	if is_coop:
		add_resurrection_timer()
		
func _process(delta):
	if !dead and !game_over and !game_manager.is_pause:
		weapon_manager.shoot(Input.is_action_just_pressed("shoot" + player_number), Input.is_action_pressed("shoot" + player_number))
		if is_controller:
			if Input.is_action_pressed("controller_look_up") or Input.is_action_pressed("controller_look_down") or Input.is_action_pressed("controller_look_left") or Input.is_action_pressed("controller_look_right"):
				controller_move_cursor(delta)

func _physics_process(delta):
	camera_follows_player()
	if !is_controller:
		look_at_cursor()
	#else:
	#	if Input.is_action_pressed("controller_look_up") or Input.is_action_pressed("controller_look_down") or Input.is_action_pressed("controller_look_left") or Input.is_action_pressed("controller_look_right"):
	#		controller_move_cursor(delta)
	move(delta)
	animate_move()
	
	velocity *= friction
	velocity.y -= gravity*delta
	velocity = move_and_slide(velocity, Vector3.UP, true, 3)

func camera_follows_player():
	var player_position = global_transform.origin
	camera_rig.global_transform.origin = player_position

func look_at_cursor():
	if !dead and !game_manager.is_pause:
		var player_position = global_transform.origin
		var dropPlane  = Plane(Vector3(0, 1, 0), player_position.y)

		var ray_length = 1000
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * ray_length
		var cursor_pos = dropPlane.intersects_ray(from,to)
		
		cursor.global_transform.origin = cursor_pos + Vector3(0,1,0)
		
		look_at(cursor_pos, Vector3.UP)

func controller_move_cursor(delta):
	if !dead:
		cursor_move_direction = Vector3()
		var controller_cursor_basis = camera.get_global_transform().basis
		if Input.is_action_pressed("controller_look_up"):
			cursor_move_direction += controller_cursor_basis.z
			#cursor_move_direction -= Vector3(0,0,1)
			#animation_player.play("RunForward-loop")
		elif Input.is_action_pressed("controller_look_down"):
			cursor_move_direction -= controller_cursor_basis.z
			#animation_player.play("RunBackward-loop")
		if Input.is_action_pressed("controller_look_left"):
			cursor_move_direction += controller_cursor_basis.x
			#cursor_move_direction -= Vector3(1,0,0)
			#animation_player.play("RunLeft-loop")
		elif Input.is_action_pressed("controller_look_right"):
			cursor_move_direction -= controller_cursor_basis.x
			#cursor_move_direction += Vector3(1,0,0)
			#animation_player.play("RunRight-loop")
		cursor_move_direction.y = 0
		cursor_move_direction = cursor_move_direction.normalized()

		self.rotation.y = lerp_angle(self.rotation.y, atan2(cursor_move_direction.x, cursor_move_direction.z), delta * 4)
		#self.rotation.y = atan2(cursor_move_direction.x, cursor_move_direction.z)
		#cursor_velocity += cursor_move_direction*cursor_speed*delta

		#cursor_velocity *= cursor_friction
		#cursor_velocity.y -= cursor_gravity*delta
		#cursor_velocity = controller_cursor.move_and_slide(cursor_velocity, Vector3.UP, true, 3)


func move(delta):
	if !dead:
		move_direction = Vector3()
		var camera_basis = camera.get_global_transform().basis
		if Input.is_action_pressed("move_forward" + player_number):
			move_direction -= camera_basis.z
			#animation_player.play("RunForward-loop")
		elif Input.is_action_pressed("move_backward" + player_number):
			move_direction += camera_basis.z
			#animation_player.play("RunBackward-loop")
		if Input.is_action_pressed("move_left" + player_number):
			move_direction -= camera_basis.x
			#animation_player.play("RunLeft-loop")
		elif Input.is_action_pressed("move_right" + player_number):
			move_direction += camera_basis.x
			#animation_player.play("RunRight-loop")
		move_direction.y = 0
		move_direction = move_direction.normalized()
		if Input.is_action_just_pressed("dash" + player_number) and (can_dash or is_speed_boost_on):
			velocity += move_direction*speed*delta*dash_speed
			start_dash_delay()
		else:
			velocity += move_direction*speed*delta

	#else:
	#	animation_player.play("CombatIdle-loop")

func animate_move():
	if !dead and !game_manager.is_pause:
		if !Input.is_action_pressed("move_forward" + player_number) or !Input.is_action_pressed("move_backward" + player_number) or !Input.is_action_pressed("move_left" + player_number) or !Input.is_action_pressed("move_right" + player_number) or !Input.is_action_pressed("dash" + player_number):
			if Input.is_action_pressed("move_forward" + player_number):
				animation_player.play("RunForward-loop")
			elif Input.is_action_pressed("move_backward" + player_number):
				animation_player.play("RunBackward-loop")
			elif Input.is_action_pressed("move_left" + player_number):
				animation_player.play("RunLeft-loop")
			elif Input.is_action_pressed("move_right" + player_number):
				animation_player.play("RunRight-loop")
			elif Input.is_action_just_pressed("dash" + player_number):
				pass
			else:
				animation_player.play("AimFireRifle")

func take_damage(dmg : int):
	if !dead:
		if !is_invulnerability_on:
			health_manager.take_damage(dmg)
		else:
			play_invulnerability_sound()

func death():
	dead = true
	death_animation()
	emit_signal("player_death")
	if is_coop and !game_manager.is_game_over: #Hacky fix but I couldn't figure what the problem was
		add_resurrection_timer()
		start_resurrection_timer()
	
	if is_coop and game_manager.is_game_over: #Hacky fix but I couldn't figure what the problem was
		death_hud.hide()
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
		speed_powerup_effect.emitting = true
		powerup.queue_free()

func stop_speed_boost():
	is_speed_boost_on = false
	speed = default_speed
	dash_speed = default_dash_speed
	speed_boost_timer.stop()
	soundmanager.play_sound(1,10)
	speed_powerup_effect.emitting = false

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

func death_animation():
	animation_player.play("Slide")
	weapon_manager.current_weapon.hide()

func resurrect():
	weapon_manager.current_weapon.show()
	dead = false
	health_manager.set_health_forced(100)
	emit_signal("player_resurrect")

func add_resurrection_timer():
	resurrection_timer = Timer.new()
	resurrection_timer.wait_time = resurrection_wait_time
	resurrection_timer.connect("timeout", self, "resurrect")
	resurrection_timer.one_shot = true
	add_child(resurrection_timer)

func start_resurrection_timer():
	resurrection_timer.start()

func stop_resurrection_timer():
	print("RESURRECTION TIMER STOPPED: ", self.name)
	resurrection_timer.set_paused(true)

func get_resurrection_time():
	return resurrection_timer.get_time_left()

func start_dash_delay():
	can_dash = false
	dash_timer.start()

func stop_dash_delay():
	can_dash = true
