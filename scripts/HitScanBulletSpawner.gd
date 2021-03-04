extends Spatial

onready var bullet_hit_effect_prefab = preload("res://scenes/BulletHitEffect.tscn")
onready var lightning_hit_effect_prefab = preload("res://scenes/LightningHitEffect.tscn")

export var is_lightning_gun : bool = false

var hit_effect

export var distance = 10000
var bodies_to_exclude = []
var damage = 1 #add weapon damage to this
var original_damage = damage

func _ready():
	if is_lightning_gun:
		hit_effect = lightning_hit_effect_prefab
	else:
		hit_effect = bullet_hit_effect_prefab

func set_damage(_damage: int):
	damage = _damage

func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude

func fire():
	var space_state = get_world().get_direct_space_state() #take physical space where shot
	var our_pos = global_transform.origin
	var result = space_state.intersect_ray(our_pos, our_pos - global_transform.basis.z * distance, 
		bodies_to_exclude, 1 + 32, true, true) # 1 = environment, 32 = enemy hitbox layer
	if result and result.collider.has_method("take_damage"):
		result.collider.take_damage(damage)
	elif result:
		var hit_effect_inst = hit_effect.instance()
		get_tree().get_root().add_child(hit_effect_inst)
		hit_effect_inst.global_transform.origin = result.position
		
		if result.normal.angle_to(Vector3.UP) < 0.00005: #a magic number for a very small value
			return
		if result.normal.angle_to(Vector3.DOWN) < 0.00005:
			hit_effect_inst.rotate(Vector3.RIGHT, PI)
			return
		
		var y = result.normal
		var x = y.cross(Vector3.UP)
		var z = x.cross(y)
		
		hit_effect_inst.global_transform.basis = Basis(x, y, z)
