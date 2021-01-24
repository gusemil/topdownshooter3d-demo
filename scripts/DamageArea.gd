extends Area

var bodies_to_exclude = []
var damage = 1 #default unmodified damage

func set_damage(_damage: int):
	damage = _damage

func set_bodies_to_exclude(_bodies_to_exclude: Array):
	bodies_to_exclude = _bodies_to_exclude

func activate_damage_area():
	print("attack")
	for body in get_overlapping_bodies():
		if body.has_method("take_damage") and !body in bodies_to_exclude:
			body.take_damage(damage)
			#body.take_damage(damage, global_transform.origin.direction_to(body.global_transform.origin))
