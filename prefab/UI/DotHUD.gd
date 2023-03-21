extends Control
class_name DotHUD

@onready var poison_bar:= $HBoxContainer/PoisonProgress
@onready var lightning_bar:= $HBoxContainer/LightningProgress
@onready var fire_bar:= $HBoxContainer/FireProgress
@onready var ice_bar:= $HBoxContainer/IceProgress
@export var fire_icon: Texture
@export var lightning_icon: Texture
@export var poison_icon: Texture
@export var ice_icon: Texture

func _ready():
	fire_bar.texture_progress = fire_icon
	poison_bar.texture_progress = poison_icon
	lightning_bar.texture_progress = lightning_icon
	ice_bar.texture_progress = ice_icon
	for bar in $HBoxContainer.get_children():
		bar.visible = false
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
	bar.visible = true
	var tween = self.create_tween()
	tween.tween_property(bar, "value", 0, count)
	tween.tween_callback(bar.hide)
	tween.tween_callback(tween.kill)
