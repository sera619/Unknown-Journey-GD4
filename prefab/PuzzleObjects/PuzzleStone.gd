extends Node2D



@export var active_time: int 
@export var stone_id: int

@onready var timer:Timer = $Timer
@onready var text_sprite: Sprite2D = $Text
@onready var player_detector: PlayerDetector = $PlayerDetector
var is_active: bool = false

func _ready():
	timer.connect("timeout", deactivate)

func _input(event):
	if not player_detector.can_see_player() or is_active:
		return
	if event.is_action_pressed("interact"):
		activate()

func deactivate():
	is_active = false
	text_sprite.visible = false
	EventHandler.emit_signal("puzzle_deactivated", stone_id)

func activate():
	is_active = true
	timer.wait_time = active_time
	timer.start()
	text_sprite.visible = true
	EventHandler.emit_signal("puzzle_activated", stone_id)
