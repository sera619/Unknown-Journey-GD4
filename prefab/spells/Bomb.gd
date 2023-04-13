extends Node2D

@export var explotion_time: int
@export var bomb_damage: int
@export var effect_scene: PackedScene
@export var sound_scene: PackedScene
@onready var timer = $Timer
@onready var knockback_vector: Vector2 = Vector2()
@onready var body = $Body
@onready var shadow = $Shadow
@onready var hitbox = $Hitbox
@onready var collider = $Hitbox/CollisionShape2D


func _ready():
	hitbox.damage = bomb_damage
	timer.connect("timeout", _explode)
	timer.start(explotion_time)
	body.play("bomb")

func _enable_collider():
	collider.set_deferred("disabled", false)
	await get_tree().create_timer(0.5).timeout
	_kill()
	
func _explode():
	body.stop()
	shadow.hide()
	body.hide()
	if sound_scene:
		var sound = sound_scene.instantiate()
		GameManager.current_world.game_map.add_child(sound)
		sound.global_position = global_position
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = body.global_position + body.offset
	_enable_collider()

func _kill():
	call_deferred("queue_free")
