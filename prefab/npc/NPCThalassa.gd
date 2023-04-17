extends NPCBase

@onready var speak_icon: Sprite2D = $SpeakIcon
@onready var interaction_zone: Area2D = $InteractionZone
var is_talking: bool = false

func _ready():
	_on_ready()


func _physics_process(delta):
	if velocity != Vector2.ZERO: 
		animtree.set("parameters/Move/blend_position", velocity)
		animtree.set("parameters/Cast/blend_position", velocity)
		animtree.set("parameters/Dead/blend_position", velocity)
		animtree.set("parameters/Hurt/blend_position", velocity)
		animtree.set("parameters/Heal/blend_position", velocity)
		animtree.set("parameters/Idle/blend_position", velocity)
		animstate.travel("Move")
	else:
		animstate.travel("Idle")
	
	if player_detector.player != null:
		speak_icon.visible = true
	else:
		speak_icon.visible = false
	
	match state:
		IDLE:
			idle_state(delta)
		WANDER:
			wander_state(delta)
		CHASE:
			chase_state(delta)
	
	move_and_slide()

func interact():
	if not is_talking:
		is_talking = true
		dialog_handler()
	else:
		return

func chase_state(_delta):
	state = IDLE
	pass

func dialog_handler():
	var dialog: DialogBox = GameManager.dialog_box
	dialog.set_speaker(self)
	if not QuestManager.current_quest and not QuestManager.is_quest_availble("Ernte"):
		if QuestManager.is_quest_availble("Danika"):
			QuestManager.activate_quest("Danika")
			var quest: Quest = QuestManager.current_quest
			dialog.set_dialog_text(quest.start_text)
			dialog.show_dialog()
		else:
			return
	elif QuestManager.current_quest:
		var quest: Quest = QuestManager.current_quest
		if quest.title == "Danika":
			match quest.state:
				Quest.QS.ACTIVE:
					dialog.set_dialog_text(quest.progress_text)
					dialog.show_dialog()
					
	else:
		dialog.set_dialog_text(default_text)
		dialog.show_dialog()
