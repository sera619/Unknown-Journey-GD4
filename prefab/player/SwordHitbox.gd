extends Area2D
class_name PlayerSword

@export var knockback_vector: Vector2

@onready var damage: int = 0
@onready var max_damage: int = 0

var normal_dmg: int = 0
enum Type {
	NORMAL,
	HEAVY,
	DOUBLE
}
var attack_type = Type.NORMAL


func _ready():
	EventHandler.connect("player_maxdamage_changed", set_sword_max_damage)
	EventHandler.connect("player_damage_changed", set_sword_damage)


func set_sword_damage(dmg):
	self.damage = dmg
	if GameManager.player != null:
		if normal_dmg != GameManager.player.stats.damage:
			normal_dmg = GameManager.player.stats.damage

func set_sword_max_damage(max_dmg):
	self.max_damage = max_dmg

func set_attack_type(new_type: String):
	match new_type:
		"Normal":
			attack_type = Type.NORMAL
			set_sword_damage(normal_dmg)
		"Heavy":
			attack_type = Type.HEAVY
			set_sword_damage(normal_dmg * 1.3)
		"Double":
			attack_type = Type.DOUBLE
			set_sword_damage(normal_dmg * 1.15)
