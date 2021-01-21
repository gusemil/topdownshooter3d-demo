extends Spatial

export var destroy_after_seconds : float

#timer to destroy after 3 secs
func _ready():
	var timer = Timer.new()
	self.add_child(timer)
	
	timer.connect("timeout", self, "queue_free")
	timer.set_wait_time(destroy_after_seconds)
	timer.start()

