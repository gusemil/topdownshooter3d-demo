extends Area

func _ready():
	connect("area_entered", self, "on_pickup")
	
func on_pickup(pickup : Pickup):
	if pickup.pickup_type == pickup.PICKUP_TYPES.AMMO_MACHINE_GUN:
		print("ASDFF")
		pickup.queue_free()
