extends Control

@export var check_quest_icon: Texture2D
@export var active_quest_icon: Texture2D
@onready var questinfo_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuestInfoLabel
@onready var questtitle_label:Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuestNameLabel
@onready var quest_list: ItemList = $Panel/MarginContainer/VBoxContainer/HBoxContainer/ItemList
@onready var quest_quantity_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuestQuantityLabel
@onready var quest_finish_label: Label = $Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/QuestFinishLabel
@onready var activate_button: TextureButton =$Panel/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/SetActiveButton
