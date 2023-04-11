extends WorldBase

@onready var lava_damage = $Map/Bricks/LavaDamage

func _ready():
	_on_ready()
	get_tree().call_group("world_light", "_light_on")
	lava_damage.damage = 10


