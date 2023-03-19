extends Area2D


func _ready():
	self.connect("body_entered", give_player_weapon)


func give_player_weapon(body):
	if body.name != 'Player':
		return
	var stats = GameManager.player.stats
	if not stats.has_sword:
		stats.has_sword = true
		GameManager.player.set_sprite(1)
