extends Area2D
class_name DevUtil

@export_enum("Take Damage", "Get Exp") var touch_type: int
@export var exp_to_add: int
@export var dmg_to_add: int
@onready var knockback_vector: Vector2 =Vector2.LEFT
@onready var damage: int = 0

func _ready():
	if dmg_to_add != 0:
		damage = dmg_to_add
	self.connect("body_entered", get_effect)
	

func get_effect(body):
	if body.name != "Player":
		return
	var player: Player = body
	match touch_type:
		0:
			if dmg_to_add != 0:
				damage = dmg_to_add
		1:
			if exp_to_add != 0:
				player.stats.set_exp(player.stats.experience + exp_to_add)
