extends Node2D


@export var effect_scene: PackedScene
@export var respawn: bool
@export var respawn_time:int 

@onready var animsprite: AnimatedSprite2D = $Sprite2D2
@onready var hitbox = $Hitbox
@onready var timer = $Timer
@onready var shape = $Hitbox/CollisionShape2D


func _ready():
	hitbox.connect("area_entered", destroy)
	animsprite.connect("animation_finished", disable)
	if respawn:
		timer.connect("timeout", reset)


func destroy(area):
	if not area.is_in_group("playerSword"):
		return
	var effect = effect_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.global_position = animsprite.global_position
	animsprite.play("animate")

func disable():
	$Sprite2D.visible = false
	animsprite.stop()
	animsprite.frame = 0
	animsprite.visible = false
	shape.call_deferred("set_disabled",true)
	if respawn:
		timer.wait_time = respawn_time
		timer.start()

func reset():
	$Sprite2D.visible = true
	animsprite.visible = true
	shape.call_deferred("set_disabled",false)
	
