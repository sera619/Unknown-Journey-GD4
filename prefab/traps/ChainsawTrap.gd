extends Node2D
@export var trap_damage: int
@export var is_on: bool
@export var pathfollow_path: NodePath
@export var move_time: int
@export var wait_time: int

@onready var body = $Body
@onready var hitbox: EnemyWeapon = $Hitbox
@onready var shadow = $Shadow
@onready var timer = $Timer

var pathfollow: PathFollow2D = null
var can_move: bool = true
var is_right_side: bool = true

func _ready():
	self._setup_trap()
	timer.connect("timeout", _on_timeout)
	trap_on()

func _on_timeout():
	move_trap()

func _setup_trap():
	if pathfollow_path:
		pathfollow = get_node(pathfollow_path)
	hitbox.damage = self.trap_damage

func set_side():
	if is_right_side:
		is_right_side = false
	else:
		is_right_side = true

func move_trap():
	if is_right_side and is_on:
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(pathfollow, "progress_ratio", 1, move_time)
		tween.tween_callback(set_side)
		if wait_time == 0:
			tween.tween_callback(move_trap)
		tween.tween_callback(tween.kill)
	elif not is_right_side and is_on:
		var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(pathfollow, "progress_ratio", 0, move_time)
		tween.tween_callback(set_side)
		if wait_time == 0:
			tween.tween_callback(move_trap)
		tween.tween_callback(tween.kill)

func trap_on():
	body.play("on")
	move_trap()
	is_on = true

func trap_off():
	body.play("off")
	is_on = false
