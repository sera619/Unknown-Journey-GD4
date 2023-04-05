extends Node2D
class_name StatisticBook

@onready var player_detector: PlayerDetector = $PlayerDetector
@onready var body_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var icon: Sprite2D = $Icon

var is_showing: bool = false

func _ready():
	body_sprite.connect("animation_finished", open_statistic)

func _process(delta):
	if player_detector.can_see_player():
		icon.visible = true
		if Input.is_action_just_released("interact"):
			if not body_sprite.is_playing():
				body_sprite.play("default")
	else:
		icon.visible = false

func open_statistic():
	GameManager.interface.statistic_hud.show_statistic()
