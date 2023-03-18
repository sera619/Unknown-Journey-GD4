extends Node
class_name QuestSystem

@export_category("Quest List")
@export var ALL_QUESTS: Array[Quest]

var player_questlog: Dictionary = {}
var current_quest: Quest

func _ready():
	GameManager.register_node(self)
	player_questlog = _create_new_player_questlog()



func _create_new_player_questlog() -> Dictionary:
	var new = {}
	for quest in ALL_QUESTS:
		new[str(quest.quest_name)] = quest
	return new

func _get_current_quest_state(questname: String):
	if player_questlog.is_empty():
		printerr("[X] PlayerQuestLog: Log is empty")
		return
	var state = player_questlog[questname].quest_state
	return state

func _add_quest_item(questname: String):
	if player_questlog.is_empty():
		printerr("[X] PlayerQuestLog: Log is empty")
		return
	if player_questlog[questname].current_quantity < player_questlog[questname].required_quantity:
		player_questlog[questname].current_quantity += 1
	if _check_quest_complete(questname):
		player_questlog[questname].quest_state = Quest.QS.FINISHED
		GameManager.ui_questlog.update_questlist()
		GameManager.info_box.set_info_text("Die Quest:\n\n[color=yellow]\"%s\"[/color]\n\nkann jetzt abgegeben werden!" % questname)


func _complete_quest(questname: String):
	if _check_quest_complete(questname):
		_reward_player(questname)
		GameManager.ui_questlog.update_questlist()
		GameManager.info_box.set_info_text("[center]Die Quest:\n\n[color=yellow]\"%s\"[/color]\n\nist abgeschlossen![/center]" % questname)

func _reward_player(questname: String):
	if player_questlog[questname].quest_state == Quest.QS.COMPLETE:
		return
	if player_questlog[questname].reward_xp != 0:
		GameManager.player.stats.set_exp(GameManager.player.stats.experience + player_questlog[questname].reward_xp)
	player_questlog[questname].quest_state = Quest.QS.COMPLETE

func _activate_quest(questname: String):
	if player_questlog.is_empty():
		printerr("[X] PlayerQuestLog: Log is empty")
		return
	var quest =	player_questlog[questname]
	quest.set_state(Quest.QS.ACTIVE)
	current_quest = quest
	GameManager.info_box.set_info_text("Neue Quest:\n\n[color=yellow]\"%s\"[/color]\n\nerhalten!" % questname)


func _check_quest_complete(questname: String) -> bool:
	if player_questlog.is_empty():
		printerr("[X] PlayerQuestLog: Log is empty")
		return false
	if player_questlog[questname].current_quantity == player_questlog[questname].required_quantity:
		return true
	return false
