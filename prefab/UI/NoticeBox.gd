extends Control
class_name NoticeBox


@export var notice_scene: PackedScene
@onready var notice_container: VBoxContainer = $MarginContainer/V



func show_item_notice(item:String, amount: int ):
	var notice: NoticeMessage = notice_scene.instantiate()
	notice_container.add_child(notice)
	notice.set_item_get_msg(item, amount)

func show_quest_finish_notice(questname: String):
	var notice: NoticeMessage = notice_scene.instantiate()
	notice_container.add_child(notice)
	notice.set_quest_finish_msg(questname)

func show_quest_update_notice(questname: String, amount: int, max_amount: int):
	var notice: NoticeMessage = notice_scene.instantiate()
	notice_container.add_child(notice)
	notice.set_quest_update_msg(questname, amount, max_amount)

func show_quest_complete_notice(questname: String):
	var notice: NoticeMessage = notice_scene.instantiate()
	notice_container.add_child(notice)
	notice.set_quest_complete_msg(questname)

func show_new_quest_notice(questname: String):
	var notice: NoticeMessage = notice_scene.instantiate()
	notice_container.add_child(notice)
	notice.set_quest_new_msg(questname)

func _input(event):
	if event.is_action_released("attack"):
		show_item_notice("Heiltrank", 1)
	if event.is_action_released("charpanel"):
		show_new_quest_notice("Das Schwert")
	if event.is_action_released("qlog"):
		show_quest_update_notice("Das Schwert", 1, 1)
