extends NPCNav


func dialog_handler():
	var dialog: DialogBox = GameManager.dialog_box
	dialog.set_speaker(self)
	if QuestManager.current_quest:
		var quest: Quest = QuestManager.current_quest
		if quest.title == "Finde Sarah":
			quest.add_item()
			dialog.option_a_btn.connect("button_up", _handle_quest)
			dialog.set_dialog_text(quest.complete_text)
			dialog.show_dialog()
		elif quest.title == "Wasserträger":
			match quest.state:
				Quest.QS.ACTIVE:
					dialog.set_dialog_text(quest.progress_text)
					dialog.show_dialog()
				Quest.QS.FINSIH:
					dialog.option_a_btn.connect("button_up", _handle_quest)
					dialog.set_dialog_text(quest.complete_text)
					dialog.show_dialog()
		elif quest.title == "Ernte":
			match quest.state:
				Quest.QS.ACTIVE:
					dialog.set_dialog_text(quest.progress_text)
					dialog.show_dialog()
				Quest.QS.FINSIH:
					dialog.option_a_btn.connect("button_up", _handle_quest)
					dialog.set_dialog_text(quest.complete_text)
					dialog.show_dialog()
			
	elif not QuestManager.current_quest and QuestManager.is_quest_availble("Wasserträger"):
		QuestManager.activate_quest("Wasserträger")
		var quest: Quest = QuestManager.current_quest
		dialog.set_dialog_text(quest.start_text)
		dialog.show_dialog()
	elif not QuestManager.is_quest_availble("Wasserträger") and QuestManager.is_quest_availble("Ernte"):
		QuestManager.activate_quest("Ernte")
		var quest: Quest = QuestManager.current_quest
		dialog.set_dialog_text(quest.start_text)
		dialog.show_dialog()
	else:
		dialog.set_dialog_text(T.get_random_greeting())
		dialog.show_dialog()

func _handle_quest():
	var dialog: DialogBox = GameManager.dialog_box
	dialog.option_a_btn.disconnect("button_up", _handle_quest)
	if QuestManager.current_quest.title == "Finde Sarah":
		QuestManager.current_quest.complete()
	elif QuestManager.current_quest.title == "Wasserträger":
		QuestManager.current_quest.complete()
	elif QuestManager.current_quest.title == "Ernte":
		QuestManager.current_quest.complete()
