extends Area

class_name HitBox

signal take_damage

func take_damage(damage: int):
	emit_signal("take_damage", damage)
