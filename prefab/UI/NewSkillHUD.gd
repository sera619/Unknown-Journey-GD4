extends Control
class_name NewSkillHUD

@export_category("Skill Settings")
@export var skill_name: String
@export_multiline var skill_description: String

@onready var headerlabel = $ColorRect/MarginContainer/VBoxContainer/Header
@onready var desclabel = $ColorRect/MarginContainer/VBoxContainer/Description
@onready var anim_player:AnimationPlayer = $AnimationPlayer



func _ready():
	anim_player.connect("animation_finished", _on_animation_finished)

func set_skill_text(skillname: String, text: String):
	headerlabel.text = "[center][color=green]Neue Fähigkeit![/color][color=yellow]\n[wave amp=50 freq=15]\n%s\n[/wave][/color]\n[/center]" % skillname
	desclabel.text = "[center]%s[/center]" % text
	get_tree().paused = true
	anim_player.play("show")
	

func hide_hud():
	headerlabel.text = ""
	desclabel.text = ""
	anim_player.play("hide")

func _on_animation_finished(anim_name):
	if anim_name == "hide":
		get_tree().paused = false


func _on_ok_btn_button_down():
	hide_hud()
