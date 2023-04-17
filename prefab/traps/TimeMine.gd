extends Node2D

@export var mine_damage: int
@export var explotion_scene: PackedScene

@onready var audio_stream_player_2d = $AudioStreamPlayer2D
@onready var hitbox = $Hitbox
@onready var body = $Body
@onready var player_detector = $PlayerDetector
@onready var collider = $Hitbox/CollisionShape2D


func _ready():
	hitbox.damage = mine_damage
	player_detector.connect("body_entered", _start_explode)
	body.connect("animation_finished", _explode)
	body.play("loop")


func _explode():
	if body.animation != "explode":
		return
	collider.set_deferred("disabled", false)
	var effect = explotion_scene.instantiate()
	GameManager.current_world.game_map.add_child(effect)
	effect.global_position = self.global_position
	body.visible = false
	await get_tree().create_timer(0.2).timeout
	self.queue_free()
	

func _start_explode(b):
	if b.name != "Player":
		return
	hitbox.knockback_vector = global_position.direction_to(b.global_position)
	if not audio_stream_player_2d.playing:
		audio_stream_player_2d.playing = true
	body.play("explode")
