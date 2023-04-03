extends Node2D
class_name Clock

@onready var player_detector = $PlayerDetector
@onready var anim_player = $AnimatedSprite2D

func _ready():
	anim_player.play("default")

func get_time():
	var date = Time.get_date_string_from_system()
	var time = Time.get_time_string_from_system()
	GameManager.info_box.set_info_text("[center]Es ist jetzt:\n\n[color=blue]%s Uhr[/color][/center]" % time)


func _process(delta):
	if Input.is_action_just_released("interact") and player_detector.can_see_player():
		get_time()
