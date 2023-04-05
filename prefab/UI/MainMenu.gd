extends Control
class_name MainMenu
@onready var namepopup: NamePopup = $NamePopup
@onready var menupanel: Control = $Panel/M 
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var load_btn: TextureButton = $Panel/M/V/MMLoadBtn
@onready var loadpanel: LoadMenu = $LoadMenu

func _ready():
	GameManager.register_node(self)
	anim_player.connect("animation_finished", _on_animation_finished)
	
	anim_player.play("start")


func _on_mm_start_btn_button_down():
	_create_btn_click_sound()
	print("[!] MainMenu: Start Btn clicked")
	GameManager.interface.showinfo = true
	anim_player.play("menu-name")

	
func _on_mm_load_btn_button_down():
	_create_btn_click_sound()
	print("[!] MainMenu: Load Btn clicked")
	loadpanel._initialize_loadmenu()
	anim_player.play("menu-load")

func _on_mm_option_btn_button_down():
	_create_btn_click_sound()
	print("[!] MainMenu: Option Btn clicked")
	anim_player.play("menu-option")

func _on_mm_exit_btn_button_down():
	_create_btn_click_sound()
	print("[!] MainMenu: Exit Btn clicked")
	get_tree().quit()

func start_new():
	EventHandler.disconnect("transition_black", start_new)
	GameManager.game.start_new_game()

func load_new():
	EventHandler.disconnect("transition_black", load_new)
	GameManager.game.load_game()

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_ENTER:
				anim_player.play("instant")
			elif event.keycode == KEY_C:
				if not loadpanel.visible:
					loadpanel.show_loadmenu()
				else:
					loadpanel.hide_loadmenu()

func _create_btn_click_sound():
	var sound = GameManager.interface.button_click_sound.instantiate()
	self.add_child(sound)

# Name Buttons
func _on_ok_btn_button_down():
	_create_btn_click_sound()
	GameManager.set_player_name(namepopup.nameinput.text)
	namepopup.nameinput.text = ""
	EventHandler.connect("transition_black", start_new)
	EventHandler.emit_signal("start_transition")

func _on_cancel_btn_button_down():
	_create_btn_click_sound()
	namepopup.nameinput.text = ""
	anim_player.play("name-menu")

func _on_animation_finished(anim_name):
	if anim_name == "start":
		GameManager.interface._show_alphainfo()
