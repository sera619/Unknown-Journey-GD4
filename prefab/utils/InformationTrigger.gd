extends Node2D
class_name InformationTrigger

@export_category("Information Settings")
@export_multiline var info_text: String

@onready var player_detector: PlayerDetector = $PlayerDetector

func _ready():
	player_detector.connect("body_entered", show_info)

func show_info(body):
	if body.name != "Player":
		return
	else:
		GameManager.info_box.set_info_text(info_text)

