extends WorldBase

func _ready():
	_on_ready()
	if GameManager.player.stats.has_sword:
		$Map/GameObjects/SwordDrop.queue_free()
	EventHandler.emit_signal("show_world_shadow")
	get_tree().call_group("lights", "activate_light")
