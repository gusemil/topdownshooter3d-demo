extends KinematicBody

enum STATE {IDLE, CHASE, ATTACK, DEAD}
var current_state = STATE.IDLE

var player = null #reference to the player

export var body_removes_after_seconds = 5

onready var animation_player = $Graphics/AnimationPlayer
onready var health_manager = $HealthManager

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
	print(has_player_in_line_of_sight())
	if(current_state == STATE.IDLE):
		#print("IDLE")
		pass
	elif(current_state == STATE.CHASE):
		#state_chase(delta)
		pass
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

func has_player_in_line_of_sight():
	var my_position = global_transform.origin
	var player_position = player.global_transform.origin
	
	var space_state = get_world().get_direct_space_state()
	var result = space_state.intersect_ray(my_position, player_position, [], 1) #[] exclude everything, 1 = environment
	if(result):
		return false #if something is hit in the enviroment, aka can't see player
	return true
