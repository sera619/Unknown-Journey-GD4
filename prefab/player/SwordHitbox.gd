extends Area2D
class_name PlayerSword

@export var knockback_vector: Vector2

@onready var damage: int = 0
@onready var max_damage: int = 0

func _ready():
	EventHandler.connect("player_maxdamage_changed", set_sword_max_damage)
	EventHandler.connect("player_damage_changed", set_sword_damage)

func set_sword_damage(dmg):
	self.damage = dmg

func set_sword_max_damage(max_dmg):
	self.max_damage = max_dmg
