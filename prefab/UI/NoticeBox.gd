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

func show_door_locked_notice(message: String):
	var notice: NoticeMessage = notice_scene.instantiate()
	notice_container.add_child(notice)
	notice.set_door_locked_msg(message)

func show_common_info_notice(message: String):
	var notice: NoticeMessage = notice_scene.instantiate()
	notice_container.add_child(notice)
	notice.set_information_msg(message)

func show_save_notice():
	var notice: NoticeMessage = notice_scene.instantiate()
	notice_container.add_child(notice)
	notice.set_save_msg()

func show_time_notice():
	var notice: NoticeMessage = notice_scene.instantiate()
	notice_container.add_child(notice)
	notice.set_time_msg()

#func _input(_event):
#	if GameManager.game.run_type == 1:
#		if Input.is_key_pressed(KEY_KP_7):
#			show_common_info_notice("Common Notice")
#		if Input.is_key_pressed(KEY_KP_8):
#			show_door_locked_notice("Door Locked Notice")
#		if Input.is_key_pressed(KEY_KP_9):
#			show_item_notice("Itemname", 10)
#		if Input.is_key_pressed(KEY_KP_4):
#			show_new_quest_notice("Questname new")
#		if Input.is_key_pressed(KEY_KP_5):
#			show_quest_complete_notice("Questname complete")
#		if Input.is_key_pressed(KEY_KP_6):
#			show_quest_update_notice("Questitem", 10, 10)
