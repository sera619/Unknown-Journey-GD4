extends NPCBase

var is_talking: bool = false

@export_enum("Hotel", "Labor") var world: int

func _ready():
	match world:
		0:
			GameManager.player.velocity = Vector2.ZERO
			EventHandler.emit_signal("player_set_interact", false)
			dialog_handler()
		1:
			_on_ready()

func _physics_process(_delta):
	match world:
		0:
			return
		1:
			if player_detector.can_see_player():
				if not $SpeakIcon.visible:
					$SpeakIcon.visible = true
			elif not player_detector.can_see_player():
				if $SpeakIcon.visible:
					$SpeakIcon.visible = false

func interact():
	match world:
		0:
			return
		1:
			if QuestManager.current_quest and QuestManager.current_quest.title == "Das Labor":
				QuestManager.current_quest.add_item()
			dialog_handler()

func dialog_handler():
	var dialog: DialogBox = GameManager.dialog_box
	is_talking = true
	dialog.set_speaker(self)
	if not QuestManager.current_quest:
		if QuestManager.is_quest_complete("Befreiung") and QuestManager.is_quest_availble("Das Labor"):
			match world:
				0:
					QuestManager.activate_quest("Das Labor")
					dialog.option_a_btn.connect("button_up", _handle_quest)
					var quest: Quest = QuestManager.current_quest
					dialog.set_dialog_text(quest.start_text)
					dialog.show_dialog()
				1:
					dialog.set_dialog_text(T.get_random_greeting())
					dialog.show_dialog()
		elif QuestManager.is_quest_complete("Das Labor") and QuestManager.is_quest_availble("Bombig"):
			QuestManager.activate_quest("Bombig")
			var quest: Quest = QuestManager.current_quest
			dialog.set_dialog_text(quest.start_text)
			dialog.show_dialog()
	elif QuestManager.current_quest:
		var quest: Quest = QuestManager.current_quest
		if quest.title == "Das Labor":
			match quest.state:
				Quest.QS.ACTIVE:
					dialog.set_dialog_text(quest.progress_text)
					dialog.show_dialog()
				Quest.QS.FINSIH:
					dialog.option_a_btn.connect("button_up", _handle_quest)
					dialog.set_dialog_text(quest.complete_text)
					dialog.show_dialog()
		elif quest.title == "Bombig":
			match quest.state:
				Quest.QS.ACTIVE:
					dialog.set_dialog_text(quest.progress_text)
					dialog.show_dialog()
				Quest.QS.FINSIH:
					dialog.option_a_btn.connect("button_up", _handle_quest)
					dialog.set_dialog_text(quest.complete_text)
					dialog.show_dialog()
	else:
		dialog.set_dialog_text(T.get_random_greeting())
		dialog.show_dialog()

func _handle_quest():
	var dialog: DialogBox = GameManager.dialog_box
	dialog.option_a_btn.disconnect("button_up", _handle_quest)
	if QuestManager.current_quest:
		if QuestManager.current_quest.title == "Das Labor":
			var quest = QuestManager.current_quest
			match quest.state:
				Quest.QS.ACTIVE:
					EventHandler.emit_signal("player_set_interact", true)
				Quest.QS.FINSIH:
					QuestManager.current_quest.complete()
		elif QuestManager.current_quest.title == "Bombig":
			QuestManager.current_quest.complete()
			InventoryManager.add_item("Bombe", 4)
			GameManager.interface.actionbar.bomb_btn.visible = true
			GameManager.interface.newskill_hud.set_skill_text("Bombe", "Du hast ein paar Bomben erhalten!\n\nUm sie zu scharf zu machen\n\nund zu platzieren\n\nDrücke die Taste \"3\"!")
