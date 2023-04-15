extends Node2D

@onready var animation_player = $AnimationPlayer
@onready var body = $Body
@onready var collider = $StaticBody2D/CollisionShape2D


func _ready():
	EventHandler.connect("puzzle_solved", start_displace)
	animation_player.connect("animation_finished", _disable_collider)

func start_displace():
	animation_player.play("displace")
	

func _disable_collider(_anim_name):
	collider.set_deferred("disabled", true)
