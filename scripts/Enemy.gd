extends KinematicBody

enum STATE {IDLE, CHASE, ATTACK, DEAD}
var current_state = STATE.IDLE

var player = null #reference to the player

export var body_removes_after_seconds = 5
export var sight_cone_degrees = 45.0

onready var animation_player = $Graphics/AnimationPlayer
onready var health_manager = $HealthManager

export var turn_speed_per_second = 360.0

var body_removal_timer : Timer
func _ready():
	player = get_tree().get_nodes_in_group("player")[0] # When multiplayer is implemented take the nearest player object with the tag/group "player"
	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("hurt", self, "hurt") #Hitboxin hurt signal yhdistetään tämän hurt signaliin
	
	#health_manager.connect("dead", self, "set_state", )
	set_state(STATE.IDLE)

	#body removal stuff. Started on death
	body_removal_timer = Timer.new()
	body_removal_timer.wait_time = body_removes_after_seconds
	body_removal_timer.connect("timeout", self, "remove_body")
	add_child(body_removal_timer)

func _process(delta):
	#print(has_player_in_line_of_sight())
	print(can_see_player())
	if(current_state == STATE.IDLE):
		if(can_see_player()):
			set_state(STATE.CHASE)
		pass
	elif(current_state == STATE.CHASE):
		var goal_position = player.global_transform.origin
		var my_position = global_transform.origin
		var direction = my_position.direction_to(goal_position)

		face_direction(direction, delta)
	elif(current_state == STATE.ATTACK):
		#state_attack(delta)
		pass
	elif(current_state == STATE.DEAD):
		#print("DEAD")
		pass

func set_state(state: int):
	current_state = state

	if(current_state == STATE.IDLE):
		animation_player.play("idle_loop")
	elif(current_state == STATE.DEAD):
		on_death()

func hurt(damage: int, dir : Vector3): #refactor this. Vector3 is unnecessary
	print("enemy got hit!")
	health_manager.take_damage(damage)

func state_chase(delta):
	print("CHASING")
	
func state_attack(delta):
	print("ATTACKING")
	
func disable_all_collisions():
	self.collision_layer = 0
	self.collision_mask = 0

func remove_body():
	print("remove body!")
	queue_free()

func on_death():
	animation_player.play("die")
	disable_all_collisions()
	body_removal_timer.start() #tarvitaan start obviously

func can_see_player(): #unnecessary probably
	var direction_to_player = global_transform.origin.direction_to(player.global_transform.origin) #player.(global)transform.position
	var forward = global_transform.basis.z
	return rad2deg(forward.angle_to(direction_to_player)) < sight_cone_degrees and has_player_in_line_of_sight()

func has_player_in_line_of_sight():
	var my_position = global_transform.origin + Vector3.UP #is Vector3.UP necessary?
	var player_position = player.global_transform.origin + Vector3.UP #is Vector3.UP necessary?
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(my_position, player_position, [], 1) #[] exclude everything, 1 = environment
	if(result):
		return false #if something is hit in the enviroment, aka can't see player
	return true

func face_direction(direction: Vector3, delta):
	var angle_difference = global_transform.basis.z.angle_to(direction)
	var turn_right = sign(global_transform.basis.x.dot(direction)) #sign = kertoo onko luku negatiivinen vai positiivinen (palauttaa -1 jos negatiivinen luku sisällä jne.)

	#checkataan onko nopeampaa kääntää oikealle vai vasemmalle?
	if abs(angle_difference) < deg2rad(turn_speed_per_second) * delta:		 #abs = absoluuttinen arvo
		rotation.y = atan2(direction.x, direction.z)
	else:
		rotation.y += deg2rad(turn_speed_per_second) * delta * turn_right

