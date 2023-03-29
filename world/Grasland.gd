extends WorldBase

@onready var info_trigger = $Map/GameObjects/InformationTrigger

func _ready():
	_on_ready()
	if GameManager.player != null:
		if GameManager.player.stats.has_sword:
			info_trigger.queue_free()
	$Map/WorldEffect._set_sunlight(true)
	#EventHandler.emit_signal("start_rain")
	GameManager.interface._show_alphainfo()
