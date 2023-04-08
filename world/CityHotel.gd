extends WorldBase



func _ready():
	_on_ready()
	get_tree().call_group("world_light", "_light_on")
