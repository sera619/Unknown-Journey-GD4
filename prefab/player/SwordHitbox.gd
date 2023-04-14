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
var attack_type: Type = Type.NORMAL

var attack_element = SkillManager.ELEMENT.NONE

func _ready():
	EventHandler.connect("player_maxdamage_changed", set_sword_max_damage)
	EventHandler.connect("player_damage_changed", set_sword_damage)
	self.connect("area_entered", _get_effect)

func set_element_type(new_element: String):
	match new_element:
		"None":
			attack_element = SkillManager.ELEMENT.NONE
		"Lightning":
			attack_element = SkillManager.ELEMENT.LIGHTNING
		"Fire":
			attack_element = SkillManager.ELEMENT.FIRE
		"Ice":
			attack_element = SkillManager.ELEMENT.ICE
		"Poison":
			attack_element = SkillManager.ELEMENT.POISON

func set_sword_damage(dmg):
	self.damage = dmg
	if GameManager.player != null:
		if normal_dmg != GameManager.player.stats.damage:
			normal_dmg = GameManager.player.stats.damage

func set_sword_max_damage(max_dmg):
	self.max_damage = max_dmg

func _get_effect(area):
	if InventoryManager._get_equiped_weapon() != null:
		var weapon: Item = InventoryManager._get_equiped_weapon()
		if weapon._get_weapon_effect():
			if weapon.effect_scene:
				var effect = weapon.effect_scene.instantiate()
				area.get_parent().add_child(effect)
				effect.global_position = area.get_parent().global_position
		else:
			return

func set_attack_type(new_type: String):
	match new_type:
		"Normal":
			attack_type = Type.NORMAL
			set_sword_damage(normal_dmg)
		"Heavy":
			attack_type = Type.HEAVY
			set_sword_damage(normal_dmg + 2)
		"Double":
			attack_type = Type.DOUBLE
			set_sword_damage(normal_dmg + 1)
