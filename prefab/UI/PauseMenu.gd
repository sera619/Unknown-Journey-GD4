extends Control

var paused: bool = false

func _ready():
	self.visible = false

func _input(event):
	if event.is_action_pressed("menu"):
		if GameManager.on_main_menu:
			return
		if self.visible:
			hidepause()
		else:
			showpause()

func showpause():
	self.visible = true
	get_tree().paused = true

func hidepause():
	self.visible = false
	get_tree().paused = false

func _on_p_resume_btn_button_down():
	hidepause()

func _on_p_load_btn_button_down():
	hidepause()
	EventHandler.connect("transition_black", load_game)
	EventHandler.emit_signal("start_transition")

func load_game():
	EventHandler.disconnect("transition_black", load_game)
	GameManager.game.load_game()

func go_mainmenu():
	EventHandler.disconnect("transition_black", go_mainmenu)
	GameManager.game.switch_gamelevel("MainMenu")
	

func _on_p_exit_btn_button_down():
	hidepause()
	EventHandler.connect("transition_black", go_mainmenu)
	EventHandler.emit_signal("start_transition")

