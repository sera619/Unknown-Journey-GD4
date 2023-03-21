extends Control
class_name DotHUD

@onready var poison_bar:= $NinePatchRect/MarginContainer/HBoxContainer/PoisonProgress
@onready var lightning_bar:= $NinePatchRect/MarginContainer/HBoxContainer/LightningProgress
@onready var fire_bar:= $NinePatchRect/MarginContainer/HBoxContainer/FireProgress
@onready var ice_bar:= $NinePatchRect/MarginContainer/HBoxContainer/IceProgress
@export var fire_icon: Texture
@export var lightning_icon: Texture
@export var poison_icon: Texture
@export var ice_icon: Texture
@onready var p_bg = $NinePatchRect/MarginContainer/HBoxContainer/PoisonProgress/NinePatchRect
@onready var i_bg = $NinePatchRect/MarginContainer/HBoxContainer/IceProgress/NinePatchRect
@onready var f_bg = $NinePatchRect/MarginContainer/HBoxContainer/FireProgress/NinePatchRect
@onready var l_bg = $NinePatchRect/MarginContainer/HBoxContainer/LightningProgress/NinePatchRect



func _ready():
	self.visible = false
	fire_bar.texture_progress = fire_icon
	f_bg.texture = fire_icon
	poison_bar.texture_progress = poison_icon
	p_bg.texture = poison_icon
	lightning_bar.texture_progress = lightning_icon
	l_bg.texture = lightning_icon
	ice_bar.texture_progress = ice_icon
	i_bg.texture = ice_icon
	EventHandler.connect("player_dot_start", start_progress)

func start_progress(count, element):
	var bar
	match element:
		SkillManager.ELEMENT.ICE:
			bar = ice_bar
		SkillManager.ELEMENT.POISON:
			bar = poison_bar
		SkillManager.ELEMENT.LIGHTNING:
			bar = lightning_bar
		SkillManager.ELEMENT.FIRE:
			bar = fire_bar
	bar.value = 100
	bar.visible = true
	var tween = self.create_tween()
	tween.tween_property(bar, "value", 0, count)
	tween.tween_callback(tween.kill)

