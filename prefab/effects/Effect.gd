extends Node2D


@onready var animsprite:AnimatedSprite2D = $AnimatedSprite


func _ready():
	animsprite.connect("animation_finished", on_animation_finished)
	animsprite.frame = 0
	animsprite.play("animate")

func on_animation_finished():
	self.queue_free()
