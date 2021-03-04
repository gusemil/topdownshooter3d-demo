extends KinematicBody

enum STATE {IDLE, CHASE, ATTACK, PAIN, DEAD}
var current_state = STATE.IDLE

onready var animation_player = $Graphics/AnimationPlayer
onready var health_manager = $HealthManager
onready var loot_manager = get_tree().get_root().get_node("World/LootManager")
onready var wave_manager = get_tree().get_root().get_node("World/WaveManager")
var damage_area
export var is_melee : bool
export var score_value : int

# Movement
export var turn_speed_per_second = 360.0
export var gravity = 100
export var move_acceleration = 5
var drag = 0.0
export var max_speed = 25
var movement_vector : Vector3
var move_direction = Vector3()
var velocity = Vector3()

# Attack
export var attack_range = 5.0
export var attack_rate = 1.0
export var attack_animation_speed = 0.5
export var attack_angle = 5.0
var attack_timer : Timer
var can_attack = true
export var always_face_towards_player_when_attacking = false
export var stop_moving_when_attacking = true
export var attack_damage = 10

#Pain state ala Doom
export var pain_chance : int = 3 #1/3 chance for pain state
export var pain_length : float = 0.3
var in_pain : bool = false
var pain_timer : Timer
var is_dead : bool = false

# RNG
var rng = RandomNumberGenerator.new()

# Navigation and player sensing
var players = []
var path = []
export var sight_cone_degrees = 45.0
onready var nav : Navigation = get_parent() # enemy must be a child of navigation node

signal attack

#Boss
export var is_boss : bool = false

#Sounds
onready var soundplayer : AudioStreamPlayer3D = $AudioStreamPlayer3D
var enemy_sounds = []

onready var death_sound0 : String = "res://audio/sounds/enemy_death2.wav"
onready var death_sound1 : String = "res://audio/sounds/enemy_death4.wav"
onready var death_sound2 : String = "res://audio/sounds/enemy_death1.wav"
onready var death_sound3 : String = "res://audio/sounds/enemy_death3.wav"

onready var dmg_sound4: String = "res://audio/sounds/player_damage.wav"
onready var ranged_sound5 : String = "res://audio/sounds/enemy_shoot1.wav"

# Body removal
export var body_removes_after_seconds = 5
var body_removal_timer : Timer

#Coop
var is_coop : bool
onready var game_manager = get_tree().get_root().get_node("World/GameManager")

func _ready():
	#sounds
	enemy_sounds.push_back(death_sound0)
	enemy_sounds.push_back(death_sound1)
	enemy_sounds.push_back(death_sound2)
	enemy_sounds.push_back(death_sound3)

	enemy_sounds.push_back(dmg_sound4)
	enemy_sounds.push_back(ranged_sound5)
	
	rng.randomize()
	players = get_tree().get_nodes_in_group("player")
	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("take_damage", self, "take_damage")
	
	set_state(STATE.IDLE)

	drag = float(move_acceleration) / max_speed

	body_removal_timer = Timer.new()
	body_removal_timer.wait_time = body_removes_after_seconds
	body_removal_timer.connect("timeout", self, "remove_body")
	add_child(body_removal_timer)

	# Pain
	pain_timer = Timer.new()
	pain_timer.wait_time = pain_length
	pain_timer.connect("timeout", self, "end_pain")
	pain_timer.one_shot = true
	add_child(pain_timer)

	# Attack
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)
	if is_melee:
		damage_area = $AttackArea/DamageArea
		damage_area.set_damage(attack_damage)

	health_manager.connect("dead", self, "death")

	#Coop setup
	if game_manager.is_coop:
		is_coop = true
	else:
		is_coop = false

func set_state(state: int):
	current_state = state

	if current_state == STATE.IDLE:
		animation_player.play("idle_loop")
	elif current_state == STATE.CHASE:
		animation_player.play("walk_loop", 0.2)
	elif current_state == STATE.DEAD :
		on_death()

func take_damage(damage: int):
	if !is_dead:
		health_manager.take_damage(damage)
		if !is_dead:
			if is_melee:
				play_sound(4,1)

		var pain = rng.randi_range(1,pain_chance)
		if pain == pain_chance:
			set_state(STATE.PAIN)
func disable_all_collisions():
	$CollisionShape.disabled = true #Much better collision disabling

func remove_body():
	queue_free()

func on_death():
	is_dead = true
	animation_player.play("die")
	disable_all_collisions()
	body_removal_timer.start()
	loot_manager.drop_pickup(global_transform.origin, is_boss)
	var random_death_sound = rng.randi_range(0,3)
	play_sound(random_death_sound,1.5, 25.0)
	game_manager.add_score(score_value * (wave_manager.wave_count+1))

func can_see_player():
	var direction_to_player 
	if !is_coop:
		direction_to_player = global_transform.origin.direction_to(players[0].global_transform.origin)
	else:
		direction_to_player = global_transform.origin.direction_to(get_closest_player().global_transform.origin)
	var forward = global_transform.basis.z
	return rad2deg(forward.angle_to(direction_to_player)) < sight_cone_degrees and has_player_in_line_of_sight()

func player_within_angle(angle: float):
	var direction_to_player
	if !is_coop:
		direction_to_player = global_transform.origin.direction_to(players[0].global_transform.origin)
	else:
		direction_to_player = global_transform.origin.direction_to(get_closest_player().global_transform.origin)
	var forward = global_transform.basis.z
	return rad2deg(forward.angle_to(direction_to_player)) < sight_cone_degrees

func has_player_in_line_of_sight():
	var my_position = global_transform.origin + Vector3.UP #is Vector3.UP necessary?
	var player_position
	if !is_coop:
		player_position = players[0].global_transform.origin + Vector3.UP
	else:
		player_position = get_closest_player().global_transform.origin + Vector3.UP
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(my_position, player_position, [], 1) #[] exclude everything, 1 = environment
	if(result):
		return false #if something is hit in the enviroment, aka can't see player
	return true

func face_direction(direction: Vector3, delta):
	var angle_difference = global_transform.basis.z.angle_to(direction)
	var turn_right = sign(global_transform.basis.x.dot(direction)) #sign = is number positive or negative (returns -1 if negative number and vice versa)

	#check if faster to turn left or right
	if abs(angle_difference) < deg2rad(turn_speed_per_second) * delta:		 #abs = absolute value
		rotation.y = atan2(direction.x, direction.z)
	else:
		rotation.y += deg2rad(turn_speed_per_second) * delta * turn_right

func set_movement_vector(_movement_vector : Vector3):
	movement_vector = _movement_vector.normalized()

func move(delta):
	move_direction = movement_vector
	move_direction.y = 0
	velocity += move_acceleration * movement_vector - velocity * Vector3(drag, 0, drag) + gravity * Vector3.DOWN * delta
	velocity = move_and_slide_with_snap(velocity, Vector3.DOWN, Vector3.UP)

func start_attack():
	can_attack = false
	animation_player.play("attack", -1, attack_animation_speed)
	attack_timer.start()

func finish_attack():
	can_attack = true
	if !is_melee:
		play_sound(5)

func emit_attack_signal():
	emit_signal("attack")

func start_pain():
	if !is_dead:
		in_pain = true
		animation_player.stop(true)
		animation_player.play("idle_loop")
		pain_timer.start()
	

func end_pain():
	if !is_dead:
		in_pain = false
		set_state(STATE.CHASE)

func death():
	set_state(STATE.DEAD)

func within_distance_of_player(distance: float):
	if !is_coop:
		return global_transform.origin.distance_to(players[0].global_transform.origin) < attack_range
	else:
		return global_transform.origin.distance_to(get_closest_player().global_transform.origin) < attack_range

func _process(delta):
	if(current_state == STATE.IDLE):
		if(can_see_player()):
			set_state(STATE.CHASE)
		pass

		#CHASE
	elif(current_state == STATE.CHASE):
		if within_distance_of_player(attack_range) and has_player_in_line_of_sight():
			set_state(STATE.ATTACK)
		var player_position
		if !is_coop:
			player_position = players[0].global_transform.origin
		else:
			player_position = get_closest_player().global_transform.origin
		var my_position = global_transform.origin
		path = nav.get_simple_path(my_position, player_position)
		var goal_position = player_position

		if path.size() > 1: #position 0 is the current position
			goal_position = path[1]

		var direction = goal_position - my_position
		direction.y = 0
		set_movement_vector(direction)
		face_direction(direction, delta)
		move(delta)

		#ATTACK
	elif(current_state == STATE.ATTACK):
		set_movement_vector(Vector3.ZERO)

		if always_face_towards_player_when_attacking:
			if !is_coop:
				face_direction(global_transform.origin.direction_to(players[0].global_transform.origin),delta) #always face towards player during attack
			else:
				face_direction(global_transform.origin.direction_to(get_closest_player().global_transform.origin),delta)

		if can_attack:
			if !within_distance_of_player(attack_range) or !can_see_player():
				set_state(STATE.CHASE)
			elif !player_within_angle(attack_angle) and !always_face_towards_player_when_attacking:
				if !is_coop:
					face_direction(global_transform.origin.direction_to(players[0].global_transform.origin),delta)
				else:
					face_direction(global_transform.origin.direction_to(get_closest_player().global_transform.origin),delta)
			else:
				start_attack()

		#DEAD
	elif(current_state == STATE.DEAD):
		pass

		#PAIN
	elif(current_state == STATE.PAIN):
		if !in_pain and !is_dead:
				set_movement_vector(Vector3.ZERO)
				start_pain()

func play_sound(sound_index : int, pitch_scale = 1.0, volume = 30.0):
	soundplayer.stream = load(enemy_sounds[sound_index])
	soundplayer.pitch_scale = pitch_scale
	soundplayer.unit_db = volume
	soundplayer.play()

func get_closest_player():
	if players[0].dead and !players[1].dead:
		return players[1]
	elif players[1].dead and !players[0].dead:
		return players[0]
	elif players[0].dead and players[1].dead:
		if global_transform.origin.distance_to(players[0].global_transform.origin) < global_transform.origin.distance_to(players[1].global_transform.origin):
			return players[0]
		else:
			return players[1]
	else:
		if global_transform.origin.distance_to(players[0].global_transform.origin) < global_transform.origin.distance_to(players[1].global_transform.origin):
			return players[0]
		else:
			return players[1]
