@icon("res://assets/UI/exclamation_mark.png")
extends Resource
class_name Quest
@export_category('Base Questsettings')
@export var quest_id: int
@export var quest_name: String
@export_multiline var quest_description: String

@export_category('Quest Conditions')
@export_enum('GoTo Quest', 'Kill Quest', 'Loot Quest') var quest_type: int
@export var required_quantity: int
@export var quest_mob_scene: PackedScene
@export var quest_item_scene: PackedScene

@export_category('Quest Locations')
@export var mob_spawn_node: NodePath
@export var item_spawn_node: NodePath

@export_category('Quest Reward')
@export var reward_xp: int

enum QS {
	NOT_GIVEN,
	ACTIVE,
	READY,
	FINISHED,
	COMPLETE
}

var current_quantity: int = 0
var quest_state: QS = QS.NOT_GIVEN

func get_quest_information():
	var infos = {
		"ID": quest_id,
		"name": quest_name,
		"des": quest_description,
		"cur_quantity":current_quantity,
		"state":quest_state
	}
	return infos

func set_state(state: QS):
	quest_state = state


func add_quest_items():
	if quest_state == QS.FINISHED or quest_state == QS.COMPLETE:
		return
	current_quantity += 1
	if current_quantity == required_quantity:
		set_state(QS.FINISHED)
		if GameManager.ui_questlog:
			GameManager.ui_questlog.update_questlist()
		print("[!] Quest: %s is complete!" % quest_name)

func complete_quest():
	if not GameManager.player or reward_xp == 0:
		return
	GameManager.player.stats.set_exp(reward_xp + GameManager.player.stats.experience)
	EventHandler.emit_signal("quest_complete", self)
	set_state(QS.COMPLETE)
	
