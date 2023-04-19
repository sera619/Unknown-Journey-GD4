extends Control
class_name OptionPanel

@export var dialog_scene: PackedScene
@export var hotkey_popup: PackedScene
# AUDIO
@onready var audio_all_label = $BG/M/V/AudioOptions/M/Options/V/H/Value
@onready var audio_music_label = $BG/M/V/AudioOptions/M/Options/V/H2/Value
@onready var audio_sfx_label = $BG/M/V/AudioOptions/M/Options/V/H3/Value
@onready var audio_menu_label = $BG/M/V/AudioOptions/M/Options/V/H4/Value
@onready var audio_ambiente_label = $BG/M/V/AudioOptions/M/Options/V/H6/Value

@onready var audio_all_slider = $BG/M/V/AudioOptions/M/Options/V/H/AllAudioSlider
@onready var audio_music_slider = $BG/M/V/AudioOptions/M/Options/V/H2/MusicSlider
@onready var audio_sfx_slider = $BG/M/V/AudioOptions/M/Options/V/H3/SFXSlider
@onready var audio_ambiente_slider = $BG/M/V/AudioOptions/M/Options/V/H6/AmbienteSlider
@onready var audio_menu_slider = $BG/M/V/AudioOptions/M/Options/V/H4/MenuSlider
@onready var music_mute_btn = $BG/M/V/AudioOptions/M/Options/V/H5/MMuteBtn
@onready var music_mute_icon = $BG/M/V/AudioOptions/M/Options/V/H5/MMuteBtn/CheckIcon

@onready var audio_btn = $BG/M/V/BBox/AudioBtn
@onready var video_btn = $BG/M/V/BBox/VideoBtn
@onready var key_btn = $BG/M/V/BBox/KeyBtn

@onready var audio_panel = $BG/M/V/AudioOptions
@onready var video_panel = $BG/M/V/VideoOptions
@onready var key_panel = $BG/M/V/KeyOptions

# VIDEO
@onready var screen_res_btn: CheckButton = $BG/M/V/VideoOptions/M/S/Options/H1/CheckButton
@onready var check_icon: TextureRect = $BG/M/V/VideoOptions/M/S/Options/H1/CheckButton/CheckIcon
@onready var vsync_btn: CheckButton = $BG/M/V/VideoOptions/M/S/Options/H2/CheckButton2
@onready var vsync_icon: TextureRect = $BG/M/V/VideoOptions/M/S/Options/H2/CheckButton2/CheckIcon

@onready var brightness_slider = $BG/M/V/VideoOptions/M/S/Options/H/BrightnessSlider
@onready var contrast_slider = $BG/M/V/VideoOptions/M/S/Options/H3/ContrastSlider
@onready var hue_slider = $BG/M/V/VideoOptions/M/S/Options/H4/HueSlider
@onready var hue_label = $BG/M/V/VideoOptions/M/S/Options/H4/Value
@onready var contrast_label = $BG/M/V/VideoOptions/M/S/Options/H3/Value
@onready var brightness_label = $BG/M/V/VideoOptions/M/S/Options/H/Value
@onready var reset_btn = $BG/M/V/H/ResetBtn

var hotkey_popup_open: bool = false
var changing_texture = null
@onready var up_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/LV/Key1/move_up
@onready var left_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/LV/Key2/move_left
@onready var right_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/LV/Key3/move_right
@onready var down_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/LV/Key4/move_down
@onready var dash_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/LV/Key5/dash
@onready var run_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/LV/Key6/run
@onready var interact_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/LV/Key7/interact
@onready var healthpot_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/LV/Key8/healthpotion
@onready var energiepot_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/LV/Key9/energiepotion
@onready var bomb_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/LV/Key10/bomb
@onready var combat_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/MV/Key4/combatmode
@onready var attack_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/MV/Key1/attack
@onready var double_attack_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/MV/Key2/double_attack
@onready var heavy_attack_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/MV/Key3/heavy_attack
@onready var charpanel_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/RV/Key1/charpanel
@onready var qlog_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/RV/Key2/qlog
@onready var inv_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/RV/Key3/inventory
@onready var menu_key_icon = $BG/M/V/KeyOptions/M/Options/ScrollContainer/H/RV/Key4/menu



func _ready():
	$BG/M/V/HeadBG/Label.add_theme_color_override("font_color", GameManager.COLORS.lightgreen_text)
	self._reset_panels()
	self._show_audio_panel()
	self._set_current_audio_values()
	self._set_current_video_values()
	#self.key_btn.disabled = true
	#self.video_btn.disabled = true
	self.hide()


func _set_current_keys():
	if D.hotkey_settings.is_empty():
		return
	for k in D.hotkey_settings.keys():
		var e = InputEventKey.new()
		e.keycode = int(D.hotkey_settings[k])
		e.physical_keycode = int(D.hotkey_settings[k])
		e.pressed = true
		var node = self.find_child(str(k))
		if node != null:
			node.texture = load("res://assets/UI/keyboard_single_icons/"+e.as_text().to_upper()+".png")

func _create_btn_click_sound():
	var sound = GameManager.interface.button_click_sound.instantiate()
	self.add_child(sound)

func _reset_panels():
	self.audio_panel.show()
	self.video_panel.hide()
	self.key_panel.hide()

func _update_audio_all():
	var value = self.audio_all_slider.value
	var old_value = AudioServer.get_bus_volume_db(1)
	if value == old_value:
		return
	GameManager._update_audio_all(value)

func _update_audio_music():
	var value = self.audio_music_slider.value
	var old_value = AudioServer.get_bus_volume_db(5)
	if value == old_value:
		return
	GameManager._update_audio_music(value)

func _update_audio_sfx():
	var value = self.audio_sfx_slider.value
	var old_value = AudioServer.get_bus_volume_db(2)
	if value == old_value:
		return
	GameManager._update_audio_sfx(value)

func _update_audio_menu():
	var value = self.audio_menu_slider.value
	var old_value = AudioServer.get_bus_volume_db(4)
	if value == old_value:
		return
	GameManager._update_audio_menu(value)

func _update_audio_ambiente():
	var value = self.audio_ambiente_slider.value
	var old_value = AudioServer.get_bus_volume_db(3)
	if value == old_value:
		return
	GameManager._update_audio_ambiente(value)

func _update_window_mode():
	if screen_res_btn.button_pressed:
		GameManager._update_window_mode(true)
		self.check_icon.visible = true
		self.screen_res_btn.text = "AN"
	else:
		GameManager._update_window_mode(false)
		self.check_icon.visible = false 
		self.screen_res_btn.text = "AUS"

func _update_vsync_mode():
	if vsync_btn.button_pressed:
		GameManager._update_vsync_mode(true)
		self.vsync_btn.text = "AN"
		self.vsync_icon.visible = true
	else:
		GameManager._update_vsync_mode(false)
		self.vsync_btn.text = "AUS"
		self.vsync_icon.visible = false

func _update_music_mute():
	if music_mute_btn.button_pressed:
		GameManager._update_musik_mute(true)
		self.music_mute_btn.text = "AUS"
		self.music_mute_icon.visible = true
	else:
		GameManager._update_musik_mute(false)
		self.music_mute_btn.text = "AN"
		self.music_mute_icon.visible = false
	

func _set_current_audio_values():
#	var all = AudioServer.get_bus_volume_db(1)
#	var music = AudioServer.get_bus_volume_db(5)
#	var sfx = AudioServer.get_bus_volume_db(2)
#	var menu = AudioServer.get_bus_volume_db(4)
#	var ambiente = AudioServer.get_bus_volume_db(3)
#	GameManager.current_game_options["audio_all"] = all
#	GameManager.current_game_options['audio_music'] = music
#	GameManager.current_game_options['audio_sfx'] = sfx
#	GameManager.current_game_options['audio_menu'] = menu
#	GameManager.current_game_options['audio_ambiente'] = ambiente
#	GameManager.current_game_options['musicmute'] = AudioServer.is_bus_mute(5)
	if GameManager.current_game_options['musicmute'] == true:
		self.music_mute_btn.button_pressed = true
		self.music_mute_btn.text = "AUS"
		self.music_mute_icon.visible = true
	else:
		self.music_mute_btn.button_pressed = false
		self.music_mute_btn.text = "AN"
		self.music_mute_icon.visible = false
	
	var options = GameManager.current_game_options
	var all = options['audio_all']
	var music = options['audio_music']
	var sfx = options['audio_sfx']
	var ambiente = options['audio_ambiente']
	var menu = options['audio_menu']
	self.audio_all_label.text = "%d DB" % all
	self.audio_music_label.text = "%d DB" % music
	self.audio_sfx_label.text = "%d DB" % sfx
	self.audio_menu_label.text = "%d DB" % menu
	self.audio_ambiente_label.text = "%d DB" % ambiente
	self.audio_all_slider.value = all
	self.audio_menu_slider.value = menu
	self.audio_music_slider.value = music
	self.audio_sfx_slider.value = sfx
	self.audio_ambiente_slider.value = ambiente


func _reset_audio_settings():
	GameManager.current_game_options["audio_all"] = 0.0
	GameManager.current_game_options['audio_music'] = 0.0
	GameManager.current_game_options['audio_sfx'] = 0.0
	GameManager.current_game_options['audio_menu'] = 0.0
	GameManager.current_game_options['audio_ambiente'] = 0.0
	GameManager.current_game_options['musicmute'] = false
	GameManager._save_settings(GameManager.current_game_options)
	AudioServer.set_bus_volume_db(1, GameManager.current_game_options["audio_all"])
	AudioServer.set_bus_volume_db(5, GameManager.current_game_options['audio_music'])
	AudioServer.set_bus_volume_db(2, GameManager.current_game_options['audio_sfx'])
	AudioServer.set_bus_volume_db(4, GameManager.current_game_options['audio_menu'])
	AudioServer.set_bus_volume_db(3, GameManager.current_game_options['audio_ambiente'])
	AudioServer.set_bus_mute(5, false)
	self.music_mute_btn.button_pressed = false
	self.music_mute_btn.text = "AN"
	self.music_mute_icon.visible = false
	self.audio_all_label.text = "%d DB" % int(GameManager.current_game_options["audio_all"])
	self.audio_music_label.text = "%d DB" % int(GameManager.current_game_options['audio_music'])
	self.audio_sfx_label.text = "%d DB" % int(GameManager.current_game_options['audio_sfx'])
	self.audio_menu_label.text = "%d DB" % int(GameManager.current_game_options['audio_menu'])
	self.audio_ambiente_label.text = "%d DB" % int(GameManager.current_game_options['audio_ambiente'])
	self.audio_all_slider.value = GameManager.current_game_options["audio_all"] 
	self.audio_menu_slider.value = GameManager.current_game_options['audio_menu']
	self.audio_music_slider.value = GameManager.current_game_options['audio_music'] 
	self.audio_sfx_slider.value = GameManager.current_game_options['audio_sfx'] 
	self.audio_ambiente_slider.value = GameManager.current_game_options['audio_ambiente']

func _reset_video_settings():
	GameManager.current_game_options['video_saturation'] = 1.0
	GameManager.current_game_options['video_contrast'] = 1.0
	GameManager.current_game_options['video_brightness'] = 1.0
	GameManager._save_settings(GameManager.current_game_options)
	GameManager._update_video_brightness(1.0)
	GameManager._update_video_contrast(1.0)
	GameManager._update_video_saturation(1.0)
	self.brightness_label.text = "%s %s" % [GameManager.current_game_options['video_brightness'] * 100, "%"]
	self.contrast_label.text = "%s %s" % [GameManager.current_game_options['video_contrast'] * 100, "%"]
	self.hue_label.text = "%s %s" % [GameManager.current_game_options['video_saturation'] * 100, "%"]
	self.hue_slider.value = GameManager.current_game_options['video_saturation']
	self.contrast_slider.value = GameManager.current_game_options['video_contrast']
	self.brightness_slider.value = GameManager.current_game_options['video_brightness']
	

func _set_current_video_values():
	var full_screen = DisplayServer.window_get_mode()
	if full_screen == DisplayServer.WINDOW_MODE_FULLSCREEN:
		self.screen_res_btn.button_pressed = true
		self.check_icon.visible = true
		self.screen_res_btn.text = "AN"
	else:
		self.screen_res_btn.button_pressed = false
		self.screen_res_btn.text = "AUS"
		check_icon.visible = false
	
	var vsync = DisplayServer.window_get_vsync_mode()
	if vsync == DisplayServer.VSYNC_ENABLED:
		self.vsync_btn.button_pressed = true
		self.vsync_icon.visible = true
		self.vsync_btn.text = "AN"
	else:
		self.vsync_btn.button_pressed = false
		self.vsync_icon.visible = false
		self.vsync_btn.text = "AUS"
	
	self.brightness_label.text = "%s %s" % [GameManager.current_game_options['video_brightness'] * 100, "%"]
	self.contrast_label.text = "%s %s" % [GameManager.current_game_options['video_contrast'] * 100, "%"]
	self.hue_label.text = "%s %s" % [GameManager.current_game_options['video_saturation'] * 100, "%"]
	self.hue_slider.value = GameManager.current_game_options['video_saturation']
	self.contrast_slider.value = GameManager.current_game_options['video_contrast']
	self.brightness_slider.value = GameManager.current_game_options['video_brightness']

func _show_audio_panel():
	self.video_btn.button_pressed = false
	self.key_btn.button_pressed = false
	self.audio_btn.button_pressed = true
	self.video_panel.hide()
	self.audio_panel.show()
	self.reset_btn.visible = true
	self.key_panel.hide()

func _show_video_panel():
	self.video_panel.show()
	self.audio_btn.button_pressed = false
	self.key_btn.button_pressed = false
	self.reset_btn.visible = true
	self.audio_panel.hide()
	self.key_panel.hide()

func _show_key_panel():
	self.audio_btn.button_pressed = false
	self.video_btn.button_pressed = false
	self.video_panel.hide()
	_set_current_keys()
#	self.reset_btn.visible = false
	self.audio_panel.hide()
	self.key_panel.show()

func _on_okay_btn_button_up():
	_create_btn_click_sound()
	GameManager._save_settings(GameManager.current_game_options)
	if GameManager.on_main_menu:
		GameManager.main_menu.anim_player.play_backwards("menu-option")
	else:
		self.hide()
		self._show_audio_panel()

func _on_back_btn_button_up():
	_create_btn_click_sound()
	if GameManager.on_main_menu:
		GameManager.main_menu.anim_player.play_backwards("menu-option")
	else:
		self.hide()
		self._show_audio_panel()

func _on_sfx_slider_value_changed(value):
	audio_sfx_label.text = "%s DB" % floor(value)
	GameManager._update_audio_sfx(value)
	
func _on_music_slider_value_changed(value):
	audio_music_label.text = "%s DB" % floor(value)
	GameManager._update_audio_music(value)

func _on_menu_slider_value_changed(value):
	audio_menu_label.text = "%s DB" % floor(value)
	GameManager._update_audio_menu(value)

func _on_all_audio_slider_value_changed(value):
	audio_all_label.text = "%s DB" % floor(value)
	GameManager._update_audio_all(value)

func _on_brightness_slider_value_changed(value):
	brightness_label.text = "%s %s" % [value * 100, "%"]
	GameManager._update_video_brightness(value)

func _on_contrast_slider_value_changed(value):
	contrast_label.text = "%s %s" % [value * 100, "%"]
	GameManager._update_video_contrast(value)

func _on_hue_slider_value_changed(value):
	hue_label.text =  "%s %s" % [value * 100, "%"]
	GameManager._update_video_saturation(value)

func _on_ambiente_slider_value_changed(value):
	audio_ambiente_label.text = "%s DB" % floor(value)
	GameManager._update_audio_ambiente(value)

# screen size button
func _on_check_button_button_up():
	_create_btn_click_sound()
	_update_window_mode()

func _on_check_button_2_button_up():
	_create_btn_click_sound()
	_update_vsync_mode()

func _on_m_mute_btn_button_up():
	_create_btn_click_sound()
	_update_music_mute()

func _show_video_reset_dialog():
	var popup = dialog_scene.instantiate()
	GameManager.interface.add_child(popup)
	popup.connect("popup_accept", _reset_video_settings)
	popup.set_text(T.ACCEPT_DIALOG_TEXT.VIDEO_RESET)

func _show_audio_reset_dialog():
	var popup = dialog_scene.instantiate()
	GameManager.interface.add_child(popup)
	popup.set_text(T.ACCEPT_DIALOG_TEXT.AUDIO_RESET)
	popup.connect("popup_accept", _reset_audio_settings)

func _show_key_reset_dialog():
	var popup = dialog_scene.instantiate()
	GameManager.interface.add_child(popup)
	popup.set_text(T.ACCEPT_DIALOG_TEXT.HOTKEY_RESET)
	popup.connect("popup_accept", _reset_hotkey_settings)

func _reset_hotkey_settings():
	D._reset_hotkey_profile()
	self._set_current_keys()

func _on_reset_btn_pressed():
	_create_btn_click_sound()
	if video_panel.visible:
		_show_video_reset_dialog()
	elif audio_panel.visible:
		_show_audio_reset_dialog()
	elif key_panel.visible:
		_show_key_reset_dialog()


func _on_audio_btn_pressed():
	_create_btn_click_sound()
	_show_audio_panel()

func _on_video_btn_pressed():
	_create_btn_click_sound()
	_show_video_panel()

func _on_key_btn_pressed():
	_create_btn_click_sound()
	_show_key_panel()

#### HOTKEY EDIT BUTTON SIGNALS ####

func _open_hotkey_popup(actionname: String, currentkey, node):
	if hotkey_popup_open:
		return
	hotkey_popup_open = true
	_create_btn_click_sound()
	var p: HotkeyPopup = hotkey_popup.instantiate()
	self.add_child(p)
	p._set_hotkey_text(actionname, currentkey, node)
	p.connect("tree_exited", _set_popup_state)

func _set_popup_state():
	hotkey_popup_open = false

func _on_move_up_edit_btn_pressed():
	_open_hotkey_popup("Oben", InputMap.action_get_events("move_up")[0].as_text(), up_key_icon)

func _on_move_left_edit_btn_pressed():
	_open_hotkey_popup("Links", InputMap.action_get_events("move_left")[0].as_text(), left_key_icon)

func _on_move_right_edit_btn_pressed():
	_open_hotkey_popup("Rechts", InputMap.action_get_events("move_right")[0].as_text(), right_key_icon)

func _on_move_down_edit_btn_pressed():
	_open_hotkey_popup("Unten", InputMap.action_get_events("move_down")[0].as_text(), down_key_icon)

func _on_dash_edit_btn_pressed():
	_open_hotkey_popup("Dash", InputMap.action_get_events("dash")[0].as_text(), dash_key_icon)

func _on_run_edit_b_tn_pressed():
	_open_hotkey_popup("Rennen", InputMap.action_get_events("run")[0].as_text(), run_key_icon)

func _on_interact_edit_btn_pressed():
	_open_hotkey_popup("Aktion", InputMap.action_get_events("interact")[0].as_text(), interact_key_icon)

func _on_h_pot_edit_btn_pressed():
	_open_hotkey_popup("Heiltrank", InputMap.action_get_events("healthpotion")[0].as_text(), healthpot_key_icon)

func _on_e_pot_edit_btn_pressed():
	_open_hotkey_popup("Energietrank", InputMap.action_get_events("energiepotion")[0].as_text(), energiepot_key_icon)

func _on_bomb_edit_btn_pressed():
	_open_hotkey_popup("Bombe", InputMap.action_get_events("bomb")[0].as_text(), bomb_key_icon)

func _on_combat_edit_b_tn_pressed():
	_open_hotkey_popup("Kampfmodus", InputMap.action_get_events("combatmode")[0].as_text(), combat_key_icon)

func _on_attack_edit_btn_pressed():
	_open_hotkey_popup("Angriff", InputMap.action_get_events("attack")[0].as_text(),attack_key_icon)

func _on_double_attack_edit_btn_pressed():
	_open_hotkey_popup("Doppelangriff", InputMap.action_get_events("double_attack")[0].as_text(), double_attack_key_icon)

func _on_heavy_attack_edit_btn_pressed():
	_open_hotkey_popup("Wirbelangriff", InputMap.action_get_events("heavy_attack")[0].as_text(), heavy_attack_key_icon)

func _on_charpanel_edit_btn_pressed():
	_open_hotkey_popup("CharakterHUD", InputMap.action_get_events("charpanel")[0].as_text(), charpanel_key_icon)

func _on_qlog_edit_btn_pressed():
	_open_hotkey_popup("QuestlogHUD", InputMap.action_get_events("qlog")[0].as_text(), qlog_key_icon)

func _on_inventory_edit_btn_pressed():
	_open_hotkey_popup("InventarHUD", InputMap.action_get_events("inventory")[0].as_text(), inv_key_icon)

func _on_menu_edit_btn_pressed():
	_open_hotkey_popup("Pause/Menü", InputMap.action_get_events("menu")[0].as_text(), menu_key_icon)
