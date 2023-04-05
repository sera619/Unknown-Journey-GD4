extends Control
class_name PauseMenu

var paused: bool = false

@export var pause_sound_scene: PackedScene
@export var unpause_sound_scene: PackedScene
@onready var load_btn:= $BG/M/V/V/PLoadBtn
@onready var header: Label = $BG/M/V/NinePatchRect/Head
@onready var time_label: Label = $BG/M/V/TimeLabel


func _ready():
	self.visible = false
	header.add_theme_color_override("font_color", GameManager.COLORS.lightgreen_text)
	time_label.add_theme_color_override("font_color", GameManager.COLORS.orange_text)

func _input(event):
	if event.is_action_pressed("menu"):
		if GameManager.on_main_menu:
			return
		if self.visible:
			hidepause()
		else:
			showpause()

func _process(delta):
	if self.visible:
		self.time_label.text = "%s Uhr" % Time.get_time_string_from_system()

func _create_btn_click_sound():
	var sound = GameManager.interface.button_click_sound.instantiate()
	self.add_child(sound)

func showpause():
	self.visible = true
	var sound = pause_sound_scene.instantiate()
	self.add_child(sound)
	self.time_label.text = "%s Uhr" %Time.get_time_string_from_system()
	get_tree().paused = true

func hidepause():
	self.visible = false
	get_tree().paused = false
	var sound = unpause_sound_scene.instantiate()
	self.add_child(sound)

func _on_p_resume_btn_button_down():
	hidepause()

func _on_p_load_btn_button_down():
	_create_btn_click_sound()
	GameManager.interface.load_menu.show_loadmenu()

func load_game():
	EventHandler.disconnect("transition_black", load_game)
	GameManager.game.load_game()

func go_mainmenu():
	EventHandler.disconnect("transition_black", go_mainmenu)
	GameManager.game.call_deferred("switch_gamelevel", "MainMenu")
	

func _on_p_exit_btn_button_down():
	hidepause()
	GameManager.interface.hide_ui()
	EventHandler.connect("transition_black", go_mainmenu)
	EventHandler.emit_signal("start_transition")

func _on_p_option_btn_button_up():
	_create_btn_click_sound()
	GameManager.interface.option_panel.show()
	
