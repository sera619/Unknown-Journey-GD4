extends Node
class_name EnemyStats

signal enemy_health_changed(health)
signal enemy_maxhealth_changed(max_health)

signal enemy_died
signal enemy_take_damage
signal enemy_healed

@export_category('Stats Settings')
@export_group('Health Settings')
@export var max_health: int
@export var healt_reg_rate: float
@export var damage: int

@export_category('Movement Settings')
@export_group('Base Movement')
@export var MAX_SPEED:int# = 50
@export var ACCELERATION:int# = 300
@export var FRICTION:int# = 200

@export_group('Wander Movement')
@export var WANDER_SPEED: int
@export var WANDER_TARGET_RANGE: int# = 4

@export var MIN_RANGE: int
@export var MAX_RANGE: int
@export var TIME_BEFORE_FLEE: int

@export_category("Skill Settings")
@export var heal_charges: int

@export_category('Player Rewards')
@export var reward_exp: int


@onready var health: int = 0

func _ready():
	set_max_health(max_health)
	set_health(max_health)

func set_health(new_health):
	health = new_health
	if new_health > max_health:
		health = max_health
	emit_signal("enemy_health_changed", health)
	#print("[!] Enemy - %s - : Set health to %s" % [get_parent().name, health])

func set_max_health(new_max_health):
	max_health = new_max_health
	emit_signal("enemy_maxhealth_changed", max_health)

func take_damage(dmg):
	health -= dmg
	emit_signal("enemy_health_changed", health)
	if health <= 0:
		health = 0
		emit_signal("enemy_died")
	print("[!] EnemyStats: %s get damage: %s | new health: %s" % [get_parent().name, dmg, health])
	
