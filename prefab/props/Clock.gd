extends Node2D
class_name Clock

@onready var player_detector = $PlayerDetector
@onready var anim_player = $AnimatedSprite2D
@onready var icon: Sprite2D = $Sprite2D

func _ready():
	anim_player.play("default")

func get_time():
	var time = Time.get_time_string_from_system()
	GameManager.info_box.set_info_text("[center][color=red]Es ist jetzt:[/color]\n\n[color=blue]%s Uhr[/color][/center]" % time)


func _process(_delta):
	if not player_detector.can_see_player():
		if icon.visible:
			icon.hide()
		return
	icon.show()
	if Input.is_action_just_released("interact") and player_detector.can_see_player():
		get_time()
