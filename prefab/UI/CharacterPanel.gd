extends Control
class_name CharacterPanel

@onready var damage_label = $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Damage
@onready var health_label = $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Health
@onready var name_label = $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Name
@onready var energie_label = $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Energie
@onready var level_label =  $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Level
@onready var exp_label = $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Exp


func _ready():
	hide_charpanel()

func show_charpanel():
	if GameManager.player != null:
		var s = GameManager.player.stats 
		health_label.text = "%s / %s" % [s.health, s.MAX_HEALTH]
		damage_label.text = "%s" % s.damage
		name_label.text  = "%s" % s.playername
		energie_label.text = "%s / %s" % [s.energie, s.MAX_ENERGIE]
		level_label.text = "%s" % s.level
		exp_label.text = "%s / %s" % [s.experience, s.max_experience]
	visible = true

func hide_charpanel():
	visible = false


func _on_ok_btn_button_down():
	hide_charpanel()
