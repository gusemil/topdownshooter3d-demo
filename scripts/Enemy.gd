extends KinematicBody

func _ready():
	var bone_attachments = $Graphics/Armature/Skeleton.get_children()
	for bone_attachment in bone_attachments:
		for child in bone_attachment.get_children():
			if child is HitBox:
				child.connect("hurt", self, "hurt") #Hitboxin hurt signal yhdistetään tämän hurt signaliin


func hurt(damage: int, direction: Vector3):
	print("enemy got hit!")
