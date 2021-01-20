extends Area

class_name HitBox

signal hurt

func hurt(damage: int, direction: Vector3):
	emit_signal("hurt", damage, direction)
