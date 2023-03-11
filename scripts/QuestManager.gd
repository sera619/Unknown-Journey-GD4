extends Node

var QUEST_LIST = {
	"Test": load("res://Quests/TestQuest.tres"),
	"Ungeziefer":load("res://Quests/KillBats.tres"),
	"Das Schwert": load("res://Quests/GetSword.tres")
}

var player_quest_log = []
var current_quest: Quest = null

func test_data():
	var new_q = QUEST_LIST['Ungeziefer']
	new_q.current_quantity = 2
	new_q.set_state(Quest.QS.ACTIVE)
	add_quest_to_log(new_q)
	var new_b = QUEST_LIST['Das Schwert']
	add_quest_to_log(new_b)
	
func _ready():
	#self.load_saved_quest()
	#print(current_quest.quest_name)
	#test_data()
	pass


func load_saved_quest():
	var loaded_data = GameManager.load_savegame()
	if loaded_data != null:
		for questname2 in loaded_data['quest_log_complete']:
			var quest_b = QUEST_LIST[questname2]
			quest_b.quest_state = Quest.QS.COMPLETE
			quest_b.current_quantity = quest_b.required_quantity
			player_quest_log.append(quest_b)
		for questname3 in loaded_data['quest_log_finished']:
			var quest_c = QUEST_LIST[questname3]
			quest_c.set_state(Quest.QS.FINISHED)
			player_quest_log.append(quest_c)
		for questname in loaded_data['quest_log_active']:
			var quest_a = QUEST_LIST[questname[0]]
			quest_a.quest_state = Quest.QS.ACTIVE
			quest_a.current_quantity = int(questname[1])
			player_quest_log.append(quest_a)
			if loaded_data['current_quest']:
				if questname[0] == loaded_data['current_quest']:
					set_current_quest(quest_a)


func add_quest_to_log(quest: Quest):
	if check_quest_exists(quest):
		printerr("[X] Questmanager: Quest: %s already exists!" % quest.quest_name)
		return
	if quest.quest_state == Quest.QS.NOT_GIVEN:
		GameManager.info_box.set_info_text("Neue Quest\n\"%s\"\nerhalten!" % quest.quest_name)
		quest.set_state(Quest.QS.ACTIVE)
	player_quest_log.append(quest)
	print("[!] Questmanager: Quest: %s added to log!" % quest.quest_name)

func set_current_quest(quest:Quest):
	current_quest = quest

func check_quest_exists(quest) -> bool:
	if player_quest_log.has(quest) == true:
		return true
	else:
#		printerr("[X] Questmanager: Quest not found!")
		return false



