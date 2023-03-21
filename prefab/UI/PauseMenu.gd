extends Control

var paused: bool = false
@export var pause_sound_scene: PackedScene
@export var unpause_sound_scene: PackedScene
@onready var load_btn:= $BG/M/V/V/PLoadBtn

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
	var sound = pause_sound_scene.instantiate()
	self.add_child(sound)
	if GameManager.savegame_exists():
		load_btn.disabled = false
	else:
		load_btn.disabled = true
	get_tree().paused = true

func hidepause():
	self.visible = false
	get_tree().paused = false
	var sound = unpause_sound_scene.instantiate()
	self.add_child(sound)

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
	GameManager.interface.hide_ui()
	EventHandler.connect("transition_black", go_mainmenu)
	EventHandler.emit_signal("start_transition")

