extends Control
class_name OptionPanel

# AUDIO
@onready var audio_all_label = $BG/M/V/AudioOptions/M/Options/H/Value
@onready var audio_music_label = $BG/M/V/AudioOptions/M/Options/H2/Value
@onready var audio_sfx_label = $BG/M/V/AudioOptions/M/Options/H3/Value
@onready var audio_menu_label = $BG/M/V/AudioOptions/M/Options/H4/Value

@onready var audio_all_slider = $BG/M/V/AudioOptions/M/Options/H/AllAudioSlider
@onready var audio_music_slider = $BG/M/V/AudioOptions/M/Options/H2/MusicSlider
@onready var audio_sfx_slider = $BG/M/V/AudioOptions/M/Options/H3/SFXSlider
@onready var audio_menu_slider = $BG/M/V/AudioOptions/M/Options/H4/MenuSlider
@onready var music_mute_btn = $BG/M/V/AudioOptions/M/Options/H5/MMuteBtn
@onready var music_mute_icon = $BG/M/V/AudioOptions/M/Options/H5/MMuteBtn/CheckIcon

@onready var audio_btn = $BG/M/V/BBox/AudioBtn
@onready var video_btn = $BG/M/V/BBox/VideoBtn
@onready var key_btn = $BG/M/V/BBox/KeyBtn

@onready var audio_panel = $BG/M/V/AudioOptions
@onready var video_panel = $BG/M/V/VideoOptions
@onready var key_panel = $BG/M/V/KeyOptions

# VIDEO
@onready var screen_res_btn: CheckButton = $BG/M/V/VideoOptions/M/Options/H1/CheckButton
@onready var check_icon: TextureRect = $BG/M/V/VideoOptions/M/Options/H1/CheckButton/CheckIcon
@onready var vsync_btn: CheckButton = $BG/M/V/VideoOptions/M/Options/H2/CheckButton2
@onready var vsync_icon: TextureRect = $BG/M/V/VideoOptions/M/Options/H2/CheckButton2/CheckIcon

func _ready():
	$BG/M/V/HeadBG/Label.add_theme_color_override("font_color", GameManager.COLORS.lightgreen_text)
	self._reset_panels()
	self._set_current_audio_values()
	self._set_current_video_values()
	#self.key_btn.disabled = true
	#self.video_btn.disabled = true
	self.hide()

func _create_btn_click_sound():
	var sound = GameManager.interface.button_click_sound.instantiate()
	self.add_child(sound)

func _reset_panels():
	self.audio_panel.show()
	self.video_panel.hide()
	self.key_panel.hide()

func _update_audio_all():
	var value = self.audio_all_slider.value
	var old_value = AudioServer.get_bus_volume_db(0)
	if value == old_value:
		return
	GameManager._update_audio_all(value)

func _update_audio_music():
	var value = self.audio_music_slider.value
	var old_value = AudioServer.get_bus_volume_db(1)
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
	var old_value = AudioServer.get_bus_volume_db(3)
	if value == old_value:
		return
	GameManager._update_audio_menu(value)

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
	var all = AudioServer.get_bus_volume_db(0)
	var music = AudioServer.get_bus_volume_db(3)
	var sfx = AudioServer.get_bus_volume_db(1)
	var menu = AudioServer.get_bus_volume_db(2)
	GameManager.current_game_options["audio_all"] = all
	GameManager.current_game_options['audio_music'] = music
	GameManager.current_game_options['audio_sfx'] = sfx
	GameManager.current_game_options['audio_menu'] = menu
	GameManager.current_game_options['musicmute'] = AudioServer.is_bus_mute(3)
	if GameManager.current_game_options['musicmute'] == true:
		self.music_mute_btn.button_pressed = true
		self.music_mute_btn.text = "AUS"
		self.music_mute_icon.visible = true
	else:
		self.music_mute_btn.button_pressed = false
		self.music_mute_btn.text = "AN"
		self.music_mute_icon.visible = false
		
	self.audio_all_label.text = "%d DB" % int(all)
	self.audio_music_label.text = "%d DB" % int(music)
	self.audio_sfx_label.text = "%d DB" % int(sfx)
	self.audio_menu_label.text = "%d DB" % int(menu)
	self.audio_all_slider.value = all
	self.audio_menu_slider.value = menu
	self.audio_music_slider.value = music
	self.audio_sfx_slider.value = sfx

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

func _show_audio_panel():
	self.video_panel.hide()
	self.audio_panel.show()
	self.key_panel.hide()

func _show_video_panel():
	self.video_panel.show()
	self.audio_panel.hide()
	self.key_panel.hide()

func _show_key_panel():
	self.video_panel.hide()
	self.audio_panel.hide()
	self.key_panel.show()

func _on_okay_btn_button_up():
	_create_btn_click_sound()
	if self.audio_panel.visible:
		self._update_audio_all()
		self._update_audio_menu()
		self._update_audio_music()
		self._update_audio_sfx()
		self._reset_panels()
	GameManager._save_settings(GameManager.current_game_options)
	if GameManager.on_main_menu:
		GameManager.main_menu.anim_player.play_backwards("menu-option")
	else:
		self.hide()

func _on_back_btn_button_up():
	_create_btn_click_sound()
	if GameManager.on_main_menu:
		GameManager.main_menu.anim_player.play_backwards("menu-option")
	else:
		self.hide()

func _on_sfx_slider_value_changed(value):
	audio_sfx_label.text = "%s DB" % floor(value)
	AudioServer.set_bus_volume_db(1, value)

func _on_music_slider_value_changed(value):
	audio_music_label.text = "%s DB" % floor(value)
	AudioServer.set_bus_volume_db(3, value)

func _on_menu_slider_value_changed(value):
	audio_menu_label.text = "%s DB" % floor(value)
	AudioServer.set_bus_volume_db(3, value)

func _on_all_audio_slider_value_changed(value):
	audio_all_label.text = "%s DB" % floor(value)
	AudioServer.set_bus_volume_db(0,value)

func _on_audio_btn_button_up():
	_create_btn_click_sound()
	_show_audio_panel()
	
func _on_video_btn_button_up():
	_create_btn_click_sound()
	_show_video_panel()
	
func _on_key_btn_button_up():
	_create_btn_click_sound()
	_show_key_panel()

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
