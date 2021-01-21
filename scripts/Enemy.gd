extends KinematicBody

enum STATE {IDLE, CHASE, ATTACK, DEAD}
var current_state = STATE.IDLE

onready var animation_player = $Graphics/AnimationPlayer
onready var health_manager = $HealthManager

func _ready():
	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("hurt", self, "hurt") #Hitboxin hurt signal yhdistetään tämän hurt signaliin
	
	#health_manager.connect("dead", self, "set_state", )
	set_state(STATE.IDLE)

func _process(delta):
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
		animation_player.play("die")

func hurt(damage: int, dir : Vector3):
	print("enemy got hit!")
	health_manager.take_damage(damage)

func state_chase(delta):
	print("CHASING")
	
func state_attack(delta):
	print("ATTACKING")
	
