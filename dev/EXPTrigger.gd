extends Area2D


@export var exp_to_add: int

func _ready():
	self.connect("body_entered", apply_exp)
	

func apply_exp(body):
	if body.name != 'Player':
		return
	var stats = GameManager.player.stats
	stats.set_exp(stats.experience + exp_to_add)
	print("[!] EXPTrigger: Add %s to Player Exp!" % exp_to_add)
