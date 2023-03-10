extends Node2D


@onready var spawn = $AnimatedSprite2D/ArrowSpawn
@onready var sprite = $AnimatedSprite2D
@export var arrow_scene: PackedScene
var arrow
func _ready():
	sprite.connect("frame_changed", shoot_arrow)
	arrow = arrow_scene.instantiate()
	sprite.play("idle")
	

func shoot():
	sprite.play("shoot")

func shoot_arrow(frame):
	if sprite.animation == "shoot" and frame == 4:
		get_tree().current_scene.add_child(arrow)
		# start arrow
		self.call_deferred("queue_free")
	else:
		return

	
