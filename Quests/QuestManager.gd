extends Node

@export var available_quests_list: Array[PackedScene]
@onready var available: Node = $Available
@onready var current: Node = $Current

var current_quest: Quest = null

func _ready():
	initialize_quests()

func initialize_quests():
	for quest_scene in available_quests_list:
		var quest: Quest = quest_scene.instantiate()
		available.add_child(quest)
		#print("[!] QuestManager: %s initialized!" % quest.title)

func is_quest_availble(questname: String) -> bool:
	for quest in available.get_children():
		if quest.title == questname:
			return true
	return false

func is_quest_complete(questname: String) -> bool:
	var quest: Quest = get_quest_information(questname)
	if quest != null:
		if quest.state == Quest.QS.COMPLETE:
			return true
		else:
			return false
	else:
		return false

func get_quest_information(questname: String):
	var quest = current.get_node_or_null(questname)
	if quest != null:
		var _quest_info = {
			"title": quest.title,
			"current_amount": quest.current_amount,
			"required_amount": quest.required_amount,
			"description": quest.description,
			"state": quest.state
		}
		return quest

func reset_quests():
	for quest in current.get_children():
		quest.reset()
		current.remove_child(quest)
		available.add_child(quest)
		current_quest = null
		#print("[!] QuestManager: %s successfully reseted!" % quest.title)

func activate_quest(questname: String):
	for quest in available.get_children():
		if questname != quest.title:
			continue
		available.remove_child(quest)
		current.add_child(quest)
		quest.state = Quest.QS.ACTIVE
		current_quest = quest
		print("[!] QuestManager: Quest \"%s\" activated!" % quest.title)
		GameManager.interface.notice_box.show_new_quest_notice(quest.title)

func load_quests():
	var data = D._load_profile_quest_data(GameManager.selected_playername)
	for loaded_quest in data['quest_list']:
		var quest = available.get_node(loaded_quest['title'])
		quest.state = loaded_quest['state']
		quest.current_amount = int(loaded_quest['amount'])
		available.remove_child(quest)
		current.add_child(quest)
		#print("[!] QuestManager: Quest \"%s\" successfully loaded!" % quest.title)
	if data['current_quest'] != "":
		current_quest = current.get_node(data['current_quest'])
		#print("[!] QuestManager: Current Quest is \"%s\"!" % current_quest.title)

func load_quest_data():
	var loadpath = "user://questsavegame.save"
	if not FileAccess.file_exists(loadpath):
		return 
	var save_game = FileAccess.open(loadpath, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.get_data()
		return node_data

func save_quests(playername=""):
	var savepath = "user://questsavegame.save"
	if playername != "":
		savepath = "user://%s-savegame.save" % playername
	var savegame = FileAccess.open(savepath, FileAccess.WRITE)
	var quest_list: Array = []
	for quest in current.get_children():
		var quest_data: Dictionary = {
			"title": quest.title,
			"state": quest.state,
			"amount": quest.current_amount
		}
		quest_list.append(quest_data)
	var data = {
		'current_quest': current_quest.title if current_quest else "",
		'quest_list': quest_list
	}
	var json_string = JSON.stringify(data)
	savegame.store_line(json_string)
	print("[!] QuestManager: Questdata successfully saved!")
