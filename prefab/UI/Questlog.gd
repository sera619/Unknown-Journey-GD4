extends Control

@export var check_quest_icon: Texture2D
@export var active_quest_icon: Texture2D
@onready var questinfo_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuestInfoLabel
@onready var questtitle_label:Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuestNameLabel
@onready var quest_list: ItemList = $Panel/MarginContainer/VBoxContainer/HBoxContainer/ItemList
@onready var quest_quantity_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuestQuantityLabel
@onready var quest_finish_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuestFinishLabel
@onready var activate_button: TextureButton =$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SetActiveButton
var selected_quest: Quest = null

func _ready():
	GameManager.register_node(self)
	self.visible = false
	activate_button.connect("button_down",activate_quest)
	activate_button.disabled = true
	activate_button.visible = false
	quest_finish_label.visible = false
	update_questlist()

func activate_quest():
	if selected_quest.quest_state == Quest.QS.COMPLETE:
		print("[X] Questlog: Quest %s already finished!" % selected_quest.quest_name)
		return
	QuestManager.set_current_quest(selected_quest)
	update_questlist()
	update_questlog(selected_quest)

func show_questlog():
	update_questlist()
	self.visible = true

func hide_questlog():
	self.visible = false
	reset_questinfo()
	selected_quest = null
	quest_list.deselect_all()


func update_questlog(quest: Quest):
	reset_questinfo()
	if quest == QuestManager.current_quest:
		questtitle_label.add_theme_color_override("font_color", Color(0.21960784494877, 0.80000001192093, 0.16470588743687))
	else:
		questtitle_label.add_theme_color_override("font_color",Color(1, 0.60000002384186, 0.1294117718935))
	questtitle_label.text = quest.quest_name
	questinfo_label.text = quest.quest_description
	quest_quantity_label.text = "%s:\n%s / %s" % [quest.quest_item_scene._bundled['names'][0],quest.current_quantity, quest.required_quantity]
	if quest.quest_state == Quest.QS.FINISHED:
		quest_finish_label.visible = true
	activate_button.disabled = false
	activate_button.visible = true

func update_questlist():
	quest_list.clear()
	var count = 0
	for q in QuestManager.player_quest_log:
		if q.quest_state == Quest.QS.COMPLETE:
			quest_list.add_item(q.quest_name, check_quest_icon)
			quest_list.set_item_disabled(count, true)
		elif q.quest_state == Quest.QS.FINISHED:
			quest_list.add_item(q.quest_name, check_quest_icon)
		elif q.quest_state == Quest.QS.ACTIVE and q != QuestManager.current_quest:
			quest_list.add_item(q.quest_name)
		elif QuestManager.current_quest == q:
			quest_list.add_item(q.quest_name, active_quest_icon)
		else:
			quest_list.add_item(q.quest_name)
		count += 1

func reset_questinfo():
	questinfo_label.text = ""
	questtitle_label.text = ""
	quest_quantity_label.text = ""
	quest_finish_label.visible = false
	activate_button.disabled = true
	activate_button.visible = false

func _on_item_list_item_selected(index):
	var questname = quest_list.get_item_text(index)
	var quest: Quest
	for i in QuestManager.player_quest_log:
		if i['quest_name'] == questname:
			quest = i
			break
	if quest:
		update_questlog(quest)
		selected_quest = quest
	else:
		printerr("[X] Quest: Thes quest %s didnt found!" % questname)
