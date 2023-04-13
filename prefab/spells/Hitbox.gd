extends Area2D


@onready var damage: int = 0
@onready var knockback_vector: Vector2 = Vector2()
@onready var attack_element = SkillManager.ELEMENT.NONE
@onready var attack_type = null
