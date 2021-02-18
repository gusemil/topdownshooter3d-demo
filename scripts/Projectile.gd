extends KinematicBody

export var speed = 1
export var projectile_life_time = 5
export var is_exploding_projectile = true
var damage_on_hit = 1
var explosion_damage = 1
var has_exploded = false

onready var explosion_prefab = preload("res://scenes/Explosion.tscn")

var remove_projectile_on_hit_timer : Timer
var remove_projectile_lifetime_timer : Timer

func _ready():
	remove_projectile_on_hit_timer = Timer.new()
	remove_projectile_on_hit_timer.wait_time = 0.001
	remove_projectile_on_hit_timer.connect("timeout", self, "remove_projectile")
	add_child(remove_projectile_on_hit_timer)

	remove_projectile_lifetime_timer = Timer.new()
	remove_projectile_lifetime_timer.wait_time = projectile_life_time
	remove_projectile_lifetime_timer.connect("timeout", self, "remove_projectile_lifetime")
	add_child(remove_projectile_lifetime_timer)
	remove_projectile_lifetime_timer.start()

func set_is_exploding_projectile(var _is_exploding : bool):
	is_exploding_projectile = _is_exploding
func set_projectile_speed(var _speed: float):
	speed = _speed
func set_projectile_damage_on_hit(var _damage :int):
	damage_on_hit = _damage
func set_bodies_to_exclude(_bodies_to_exclude: Array):
	#print("Bodies to exclude projectile.gd ",_bodies_to_exclude)
	for bodies in _bodies_to_exclude:
		for body in bodies: #Two arrays? WTF?
			add_collision_exception_with(body)

func set_explosion_damage(var _damage: int):
	explosion_damage = _damage
func _physics_process(delta):
	var collision : KinematicCollision = move_and_collide(-global_transform.basis.z * speed * delta)

	if collision:
		var collider = collision.collider
		if collider.has_method("take_damage"):
			collider.take_damage(damage_on_hit)
		speed = 0
		$Graphics.hide()
		$CollisionShape.disabled = true
		if is_exploding_projectile:
			explode()
		remove_projectile_on_hit_timer.start()            		
func remove_projectile():
	queue_free()
	
func remove_projectile_lifetime():
	if is_exploding_projectile:
		explode()
	queue_free()

func explode():
	if has_exploded:
		return
	has_exploded = true
	var explosion_instance = explosion_prefab.instance()
	explosion_instance.set_damage(explosion_damage)
	get_tree().get_root().add_child(explosion_instance)
	explosion_instance.global_transform.origin = global_transform.origin + Vector3(0,0,3)
	explosion_instance.explode()

