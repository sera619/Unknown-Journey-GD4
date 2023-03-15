extends CanvasLayer
class_name Interface

@export var show_devpanel: bool

@onready var qlog = $Questlog
@onready var animplayer = $AnimationPlayer
@onready var pausmenu = $PauseMenu
@onready var dialogbox = $DialogBox
@onready var stat_hud = $StatHUD
@onready var charpanel:CharacterPanel = $CharacterPanel
@onready var potion_panel= $PotionPanel

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
	dialogbox.hide_dialog()
	stat_hud.hide()
	potion_panel.hide()
	

func start_transition():
	animplayer.play("start_transition")

func transition_is_black():
	EventHandler.emit_signal("transition_black")
