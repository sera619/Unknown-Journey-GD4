extends WorldBase

@onready var shadow = $Map/CanvasModulate

func _ready():
	_on_ready()
	if GameManager.player.stats.has_sword:
		$Map/GameObjects/SwordDrop.queue_free()
	get_tree().call_group("lights", "activate_light")
