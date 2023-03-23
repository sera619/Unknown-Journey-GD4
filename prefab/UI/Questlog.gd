extends Control
class_name QuestLog

@export var finish_icon: Texture
@export var active_icon: Texture

@onready var list_node: ItemList = $Panel/M/V/H/ItemList
@onready var quest_header: Label = $Panel/M/V/H/M/NinePatchRect/MarginContainer/V/QuestHeader
@onready var quest_state: Label = $Panel/M/V/H/M/NinePatchRect/MarginContainer/V/QuestState
@onready var quest_description: Label = $Panel/M/V/H/M/NinePatchRect/MarginContainer/V/QuestDescription


func _ready():
	reset_information_text()
	quest_header.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	$Panel/M/V/NinePatchRect/Header.add_theme_color_override("font_color", GameManager.COLORS.lightgreen_text)
	quest_description.add_theme_color_override("font_color", GameManager.COLORS.blue_text)


func show_log():
	load_quest_infos()
	self.visible = true

func hide_log():
	reset_information_text()
	self.visible = false

func load_quest_infos():
	var count = 0
	list_node.clear()
	for quest in QuestManager.current.get_children():
		match quest.state:
			Quest.QS.ACTIVE:
				list_node.add_item(quest.title, active_icon)
			Quest.QS.FINSIH:
				list_node.add_item(quest.title, finish_icon)
				
			Quest.QS.COMPLETE:
				list_node.add_item(quest.title, finish_icon, false)
				list_node.set_item_disabled(count, true)
		list_node.set_item_tooltip_enabled(count, false)
		count += 1

func _on_item_list_item_selected(index):
#	if not list_node.is_item_selectable(index):
#		return
	var quest_name = list_node.get_item_text(index)
	var quest: Quest = QuestManager.get_quest_information(quest_name)
	if quest:
		quest_header.text = str(quest.title)
		quest_description.text = str(quest.description)
		if quest.state == Quest.QS.ACTIVE:
			quest_state.add_theme_color_override("font_color", GameManager.COLORS.blue_text)
			quest_state.text = "%s %s / %s" % [quest.object_name, quest.current_amount, quest.required_amount]
		elif quest.state == Quest.QS.FINSIH:
			quest_state.add_theme_color_override("font_color", GameManager.COLORS.green_text)
			quest_state.text = "Du kannst die Quest jetzt abgeben!"
		elif quest.state == Quest.QS.COMPLETE:
			quest_state.add_theme_color_override("font_color", GameManager.COLORS.green_text)
			quest_state.text = "Diese Quest ist abgeschlossen!"

func reset_information_text():
	quest_description.text = ""
	quest_header.text = ""
	quest_state.text = ""


func _on_ok_btn_button_down():
	hide_log()
