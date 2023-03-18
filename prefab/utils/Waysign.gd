extends Node2D
class_name Waysign


@export_category("Base Settings")
@export var goal_location: String
@export_enum("Left", "Right") var sign_direction: int

@export_category("Sprite Settings")
@export var right_sprite: Texture2D
@export var left_sprite: Texture2D

@onready var icon_sprite: Sprite2D = $Icon
@onready var body_sprite: Sprite2D = $Body
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var player_detector: PlayerDetector = $PlayerDetector

func _ready():
	set_body_sprite()
	player_detector.connect("body_entered", show_interact_icon)
	player_detector.connect("body_exited", hide_interact_icon)

func set_body_sprite():
	if sign_direction == 0:
		body_sprite.texture = left_sprite
		body_sprite.offset.x = -1
	else:
		body_sprite.texture = right_sprite
		body_sprite.offset.x = 1

func get_way_information():
	GameManager.info_box.set_info_text("[center]In diese Richtung geht es nach:\n\n[color=blue]\"%s\"[/color][/center]" % goal_location)

func _input(event):
	if not player_detector.can_see_player():
		return
	if event.is_action_pressed("interact"):
		get_way_information()

func show_interact_icon(body):
	if body.name != "Player":
		return
	else:
		icon_sprite.visible = true
		anim_player.play("loop")

func hide_interact_icon(body):
	if body.name != "Player":
		return
	else:
		anim_player.play("RESET")
		anim_player.stop()
		icon_sprite.visible = false
