extends Node2D

@export var time_alive: int
@export var respawn_time: int


@onready var body = $Body
@onready var player_detector: PlayerDetector = $PlayerDetector
@onready var player_collider = $PlayerDetector/CollisionShape2D
@onready var timer: Timer = $Timer
@onready var damag_zone: EnemyWeapon = $DamagZone

@onready var damage_collider: CollisionShape2D = $DamagZone/CollisionShape2D
var alive: bool = true


func _ready():
	timer.wait_time = time_alive
	damag_zone.damage = 0
	timer.connect("timeout", _on_timer_timeout)
	body.connect("animation_finished", _check_player)
	player_detector.connect("body_entered",_start_break)

func _break_brick():
	body.play("default")

func _start_break(b):
	if b.name != "Player":
		return
	timer.start()

func _check_player():
	if damage_collider != null:
		damage_collider.set_deferred("disabled", false)
	_disable_brick()

func _disable_brick():
	player_collider.set_deferred("disabled", true)
	damage_collider.set_deferred("disabled", false)
	alive = false
	if respawn_time != 0:
		timer.wait_time = respawn_time
		timer.start()
	self.hide()

func _on_timer_timeout():
	if alive:
		_break_brick()
	else:
		_enable_brick()

func _enable_brick():
	alive = true
	body.frame = 0
	timer.wait_time = time_alive
	player_collider.set_deferred("disabled", false)
	damage_collider.set_deferred("disabled", true)
	self.show()
	
	
