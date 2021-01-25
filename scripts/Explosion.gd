extends Area

export var damage = 1 #TODO LATER, Modify this by weapon/enemy damage
onready var particles = $Particles

func set_damage(var _damage : int):
	damage = _damage

func explode():
	particles.emitting = true
	var physics_query = PhysicsShapeQueryParameters.new()
	physics_query.set_transform(global_transform)
	physics_query.set_shape($CollisionShape.shape)
	physics_query.collision_mask = collision_mask
	
	var space_state = get_world().get_direct_space_state()
	var results = space_state.intersect_shape(physics_query, 32) #intersect ray mutta shape, 32 on max results oletuksena, voidaan muuttaa

	for data in results:
		if data.collider.has_method("take_damage"):
			data.collider.take_damage(damage)
