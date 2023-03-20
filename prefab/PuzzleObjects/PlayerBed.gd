extends Node2D
class_name PlayerBed

@onready var player_detector: PlayerDetector = $PlayerDetector
@onready var icon: Sprite2D = $Icon  
@onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready():
	icon.visible = false
	player_detector.connect("body_entered", _play_loop)
	player_detector.connect("body_exited", _stop_loop)

func _play_loop(body):
	if body.name != 'Player':
		return
	icon.visible = true
	anim_player.play("loop")

func _stop_loop(body):
	if body.name != 'Player':
		return
	icon.visible = false
	anim_player.stop()
	
func _input(event):
	if event.is_action_pressed("interact") and player_detector.can_see_player():
		if QuestManager.current_quest:
			var quest = QuestManager.current_quest
			if quest.title == "Mein Haus":
				quest.add_item()
		EventHandler.emit_signal("player_sleep")
