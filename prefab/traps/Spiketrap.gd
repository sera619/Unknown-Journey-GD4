extends Node2D
class_name FloorTrap

@export var trap_damage: int
@export_enum("Spike", "Fire") var trap_type: int
@onready var collider = $Hitbox/CollisionShape2D
@onready var body = $Body
@onready var player_detector = $PlayerDetector
@onready var player_collider = $PlayerDetector/CollisionShape2D
@onready var hitbox = $Hitbox


func _ready():
	body.connect("frame_changed", enable_collider)
	body.connect("animation_finished", stop_trap)
	player_detector.connect("body_entered", start_trap)
	_setup_trap()

func _setup_trap():
	hitbox.damage = trap_damage
	match trap_type:
		0:
			body.play("spike_off")
			body.offset = Vector2(0, -8)
		1:
			body.play("fire_off")
			body.offset = Vector2(0, -12)

func start_trap(b):
	if b.name != "Player":
		return
	match trap_type:
		0:
			self.body.play("spike_on")
		1:
			body.play("fire_on")

func stop_trap():
	match trap_type:
		0:
			body.play("spike_off")
			if player_detector.can_see_player():
				body.play("spike_on")
		1: 
			body.play("fire_off")
			if player_detector.can_see_player():
				body.play("fire_on")

func enable_collider():
	match trap_type:
		0:
			if body.frame == 7:
				collider.set_deferred("disabled", false)
			elif body.frame == 11:
				collider.set_deferred("disabled", true)
		1:
			if body.frame == 10:
				collider.set_deferred("disabled", false)
			elif body.frame == 11:
				collider.set_deferred("disabled", true)
