extends Area2D
class_name EnemyWeapon

@export_range(1, 4) var max_poisen_dot: int = 1
@export_range(1, 4) var max_lightning_dot: int = 1
@export_range(1, 4) var max_ice_dot: int = 1
@export_range(1, 4) var max_fire_dot: int = 1

var knockback_vector: = Vector2.ZERO
var damage
var parent
var dot_count: int = 1
var dot_damage: int = 1

const ELEMENT = SkillManager.ELEMENT
var attack_element = SkillManager.ELEMENT.NONE

func get_dot_count() -> int:
	var count = dot_count
	dot_count = 0
	return count

func get_dot_damage() -> int:
	return dot_damage

func set_element_type(new_element: String):
	match new_element:
		"None":
			attack_element = SkillManager.ELEMENT.NONE
		"Lightning":
			dot_count = max_lightning_dot
			attack_element = SkillManager.ELEMENT.LIGHTNING
		"Fire":
			dot_count = max_fire_dot
			attack_element = SkillManager.ELEMENT.FIRE
		"Ice":
			dot_count = max_ice_dot
			attack_element = SkillManager.ELEMENT.ICE
		"Poison":
			dot_count = max_poisen_dot
			attack_element = SkillManager.ELEMENT.POISON
	return
