extends Node2D

signal effect_finished
@onready var animsprite:AnimatedSprite2D = $AnimatedSprite


func _ready():
	animsprite.connect("animation_finished", on_animation_finished)
	animsprite.frame = 0
	animsprite.play("animate")

func on_animation_finished():
	emit_signal("effect_finished")
	self.queue_free()
