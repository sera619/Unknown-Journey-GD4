extends Node2D
class_name Door

@export_enum("Normal", "Metal", "Locked") var door_type: int 
@export_enum("Left", "Right") var open_side: int
@export var close_time: int
@export var locked: bool
@export var sound_open_scene: PackedScene
@export var sound_close_scene: PackedScene
@export var cell_open_sound_scene: PackedScene

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
	if open_side == 0:
		anim_sprite.flip_h = false
		anim_sprite.offset.x = -1.5
	elif open_side == 1:
		anim_sprite.offset.x = 2.5
		anim_sprite.flip_h = true
	
	if close_time != 0:
		timer.wait_time = close_time

func _process(_delta):
	if Input.is_action_just_released("interact"):
		if not player_detector.can_see_player():
			return
		if locked:
			GameManager.interface.notice_box.show_door_locked_notice("Diese Tür ist\n\nverschlossen!")
			return
		if is_open:
			_close_door()
		else:
			_open_door()

func _close_door():
	is_open = false
	if not timer.is_stopped():
		timer.stop()
	match door_type:
		0:
			var sound = sound_close_scene.instantiate()
			self.add_child(sound)
		1:
			var sound = cell_open_sound_scene.instantiate()
			self.add_child(sound)
	anim_sprite.play("close")

func _open_door():
	match door_type:
		0:
			if sound_open_scene:
				var sound = sound_open_scene.instantiate()
				self.add_child(sound)
		1: 
			if cell_open_sound_scene:
				var sound = cell_open_sound_scene.instantiate()
				self.add_child(sound)
	is_open = true
	anim_sprite.play("open")

func unlock_door():
	locked = false
	GameManager.interface.notice_box.set_information_msg("Eine Tür wurde\n\nentriegelt!")

func _on_animation_finished():
	if not is_open:
		block_shape.call_deferred("set_disabled", false)
	else:
		if close_time != 0 and timer.is_stopped():
			timer.start()
		block_shape.call_deferred("set_disabled", true)
	
