extends Node2D
class_name Door

@export_enum("Normal", "Locked") var door_type: int 
@export var close_time: int
@export var sound_open_scene: PackedScene
@export var sound_close_scene: PackedScene

@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var block_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var player_detector: PlayerDetector = $PlayerDetector
@onready var timer: Timer = $Timer

var is_open: bool = false

func _ready():
	anim_sprite.connect("animation_finished", _on_animation_finished)
	anim_sprite.animation = "open"
	anim_sprite.frame = 0
	timer.connect("timeout", _close_door)
	if close_time != 0:
		timer.wait_time = close_time

func _process(delta):
	if Input.is_action_just_released("interact"):
		if not player_detector.can_see_player():
			return
		if is_open:
			_close_door()
		else:
			_open_door()

func _close_door():
	is_open = false
	if not timer.is_stopped():
		timer.stop()
	if sound_close_scene:
		var sound = sound_close_scene.instantiate()
		self.add_child(sound)
	anim_sprite.play("close")

func _open_door():
	if sound_open_scene:
		var sound = sound_open_scene.instantiate()
		self.add_child(sound)
	match door_type:
		0:
			is_open = true
			anim_sprite.play("open")

func _on_animation_finished():
	if not is_open:
		block_shape.call_deferred("set_disabled", false)
	else:
		if close_time != 0 and timer.is_stopped():
			timer.start()
		block_shape.call_deferred("set_disabled", true)
	
