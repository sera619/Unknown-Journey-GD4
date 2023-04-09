extends Node2D


@export var trap_damage: int
@onready var collider = $Hitbox/CollisionShape2D
@onready var body = $Body
@onready var player_detector = $PlayerDetector
@onready var hitbox = $Hitbox


func _ready():
	body.connect("frame_changed", enable_collider)
	body.connect("animation_finished", stop_trap)
	player_detector.connect("body_entered", start_trap)
	hitbox.damage = trap_damage


func start_trap(b):
	if b.name != "Player":
		return 
	self.body.play("on")

func stop_trap():
	body.play("off")
	if player_detector.can_see_player():
		body.play("on")

func enable_collider():
	if body.frame == 7:
		collider.set_deferred("disabled", false)
	elif body.frame == 11:
		collider.set_deferred("disabled", true)
