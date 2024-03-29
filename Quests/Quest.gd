extends Node
class_name Quest

@export_category("Base Settings")
@export_enum("Kill Quest", "Interact Quest") var type: int
@export var title: String
@export_multiline var description: String
@export_range(1, 5) var required_amount: int
@export var object_name: String
@export var reward_xp: int
@export_category("Dialog Settings")
@export_group("Dialog Text")
@export_multiline var start_text: String
@export_multiline var progress_text: String
@export_multiline var complete_text: String

enum QS {
	NOT_GIVEN,
	ACTIVE,
	FINSIH,
	COMPLETE
}

var state: QS = QS.NOT_GIVEN
var current_amount: int = 0

func add_item():
	if self.current_amount == self.required_amount:
		return
	self.current_amount += 1
	GameManager.interface.notice_box.show_quest_update_notice(self.title, self.current_amount, self.required_amount)
	if self.current_amount == self.required_amount:
		finish()

func reset():
	self.state = QS.NOT_GIVEN
	self.current_amount = 0
	#print("[!] Quest: \"%s\" successfully reseted" % self.title)

func finish():
	self.state = QS.FINSIH
	GameManager.interface.notice_box.show_quest_finish_notice(self.title)
	print("[!] Quest: \"%s\" finished!" % self.title)


func complete():
	if self.reward_xp != 0:
		var stats = GameManager.player.stats
		stats.set_exp(stats.experience + self.reward_xp)
	QuestManager.current_quest = null
	EventHandler.emit_signal("statistic_update_quests")
	GameManager.interface.notice_box.show_quest_complete_notice(self.title)
	self.state = QS.COMPLETE
	GameManager.save_data()


