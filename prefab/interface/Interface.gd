extends CanvasLayer
class_name Interface

@export var show_devpanel: bool

@onready var qlog = $Questlog
@onready var animplayer = $AnimationPlayer
@onready var pausmenu = $PauseMenu
@onready var dialogbox = $DialogBox

func _ready():
	if show_devpanel:
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


func hide_ui():
	qlog.hide_questlog()
	dialogbox.hide_dialog()


func start_transition():
	animplayer.play("start_transition")

func transition_is_black():
	EventHandler.emit_signal("transition_black")
