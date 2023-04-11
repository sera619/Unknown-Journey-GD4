extends CharacterBody2D

@export var spell_scene: PackedScene

@onready var enemy_stats = $EnemyStats
@onready var player_detector = $PlayerDetector
@onready var hitbox = $Hitbox
@onready var spellposition = $WeaponAngle/Spellposition
@onready var animation_player = $AnimationPlayer
@onready var animation_tree = $AnimationTree
@onready var animation_state = animation_tree.get("parameters/playback")
@onready var nav_agent = $NavAgent
@onready var soft_collision = $SoftCollision
@onready var enemy_hud = $EnemyHUD

enum {
	WANDER,
	IDLE,
	CHASE,
	ATTACK,
	RETURN
}
var state = IDLE


func _attack_state():
	pass

func _wander_state():
	pass


func _idle_state():
	pass

func _chase_state():
	pass

func _cast_spell():
	var spell: EnemyProjectile = spell_scene.instantiate()



