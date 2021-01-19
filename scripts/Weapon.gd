extends Spatial

export var attack_rate = 0.2
var attack_timer : Timer
var can_attack = true

export var automatic = true
export var ammo = 100


func _ready():
	attack_timer = Timer.new()
	attack_timer.wait_time = attack_rate
	attack_timer.connect("timeout", self, "finish_attack")
	attack_timer.one_shot = true
	add_child(attack_timer)

func shoot(attack_input_just_pressed: bool, attack_input_held: bool):
	if !can_attack:
		return
	if automatic and !attack_input_held:
		return
	elif !automatic and !attack_input_just_pressed:
		return
	
	if ammo == 0:
		if attack_input_just_pressed:
			print("NO AMMO")
			#emit_signal("out_of_ammo")
		return
	
	if ammo > 0:
		ammo -= 1
		print("ammo: " + ammo)
	
#	var start_transform = bullet_emitters_base.global_transform
#	bullet_emitters_base.global_transform = fire_point.global_transform
#	for bullet_emitter in bullet_emitters:
#		bullet_emitter.fire()
#	bullet_emitters_base.global_transform = start_transform
#	anim_player.stop()
#	anim_player.play("attack")
#	emit_signal("fired")
	can_attack = false
	attack_timer.start()


func set_active():
	show()
	#$Crosshair.show()

func set_inactive():
	#anim_player.play("idle")
	hide()
	#$Crosshair.hide()
