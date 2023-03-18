extends CanvasLayer
class_name Interface

@export var show_devpanel: bool

@onready var qlog = $Questlog
@onready var animplayer = $AnimationPlayer
@onready var pausmenu = $PauseMenu
@onready var stat_hud = $StatHUD
@onready var charpanel:CharacterPanel = $CharacterPanel
@onready var potion_panel= $PotionPanel
@onready var exp_hud = $ExpHUD
@onready var dialog_box: DialogBox = $DialogBox
@onready var newskill_hud: NewSkillHUD = $NewSkillHUD

func _ready():
	if show_devpanel == true:
		$DevPanel.visible = true
	else:
		$DevPanel.visible = false
	GameManager.register_node(self)
	EventHandler.connect("start_transition", start_transition)

func _input(event):
	if GameManager.on_main_menu == true:
		return
	if event.is_action_pressed("qlog"):
		if qlog.visible:
			qlog.hide_questlog()
		else:
			qlog.show_questlog()
	if event.is_action_pressed("charpanel"):
		if charpanel.visible:
			charpanel.hide_charpanel()
		else:
			charpanel.show_charpanel()


func hide_ui():
	qlog.hide_questlog()
	stat_hud.hide()
	potion_panel.hide()
	exp_hud.hide()
	dialog_box.hide_dialog()
	

func start_transition():
	animplayer.play("start_transition")

func transition_is_black():
	EventHandler.emit_signal("transition_black")
