extends Area2D
class_name PlayerDetector

@export var detector_shape:Resource 
@onready var player: Player = null

func _ready():
	if $CollisionShape2D.shape == null:
		$CollisionShape2D.shape = detector_shape
	self.connect("body_entered", on_body_entered)
	self.connect("body_exited", on_body_exited)

func on_body_entered(body):
	if body.name != "Player":
		return
	else:
		player = body
		print("[!] Playerdector on %s : Player detected!" % self.get_parent().name)

func on_body_exited(body):
	if body.name != "Player":
		return
	else:
		player = null
		print("[!] Playerdector on %s : Player lost!" % self.get_parent().name)

func can_see_player():
	return player != null
