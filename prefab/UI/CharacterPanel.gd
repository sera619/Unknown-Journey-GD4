extends Control
class_name CharacterPanel

@onready var damage_label = $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Damage
@onready var health_label = $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Health
@onready var name_label = $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Name
@onready var energie_label = $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Energie
@onready var level_label =  $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Level
@onready var exp_label = $BG/M/V/StatsBG/MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Exp


func _ready():
	EventHandler.connect("player_health_changed", update_health)
	EventHandler.connect("player_speed_changed", update_speed)
	EventHandler.connect("player_maxhealth_changed", update_max_health)
	EventHandler.connect("player_damage_changed", update_damage)
	EventHandler.connect("player_exp_changed", update_exp)
	EventHandler.connect("player_maxexp_changed", update_max_exp)
	EventHandler.connect("player_level_changed", update_level)
	EventHandler.connect("player_maxenergie_changed", update_max_energie)
	EventHandler.connect("player_energie_changed", update_energie)
	hide_charpanel()

func show_charpanel():
	if GameManager.player and health_label.text == "Leben":
		var s = GameManager.player.stats 
		health_label.text = "%s / %s" % [s.health, s.MAX_HEALTH]
		damage_label.text = "%s" % s.damage
		name_label.text  = "%s" % s.playername
		energie_label.text = "%s / %s" % [s.energie, s.MAX_ENERGIE]
		level_label.text = "%s" % s.level
		exp_label.text = "%s / %s" % [s.experience, s.max_experience]
	visible = true

func update_max_exp(new_max_exp):
	if GameManager.player != null:
		exp_label.text = "%s / %s" % [GameManager.player.stats.experience, new_max_exp]

func update_exp(new_exp):
	if GameManager.player != null:
		exp_label.text = "%s / %s" % [new_exp, GameManager.player.stats.max_experience]
	
func update_level(new_level):
	if GameManager.player != null:

		level_label.text = "%s" % new_level

func update_health(new_health):
	if GameManager.player != null:

		health_label.text = "%s / %s" % [new_health, GameManager.player.stats.MAX_HEALTH]

func update_max_health(new_max_health):
	if GameManager.player != null:
		health_label.text = "%s / %s" % [GameManager.player.stats.health, new_max_health] 

func update_energie(new_energie):
	if GameManager.player != null:
		energie_label.text = "%s / %s" % [new_energie, GameManager.player.stats.MAX_ENERGIE]

func update_max_energie(new_max_energie):
	if GameManager.player != null:
		energie_label.text = "%s / %s" % [GameManager.player.stats.energie, new_max_energie]

func update_speed(new_speed):
	pass

func update_damage(new_damage):
	if GameManager.player != null:
		damage_label.text = "%s" % new_damage


func hide_charpanel():
	visible = false


func _on_ok_btn_button_down():
	hide_charpanel()
