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

@onready var audio_btn = $BG/M/V/BBox/AudioBtn
@onready var video_btn = $BG/M/V/BBox/VideoBtn
@onready var key_btn = $BG/M/V/BBox/KeyBtn

@onready var audio_panel = $BG/M/V/AudioOptions
@onready var video_panel = $BG/M/V/VideoOptions
@onready var key_panel = $BG/M/V/KeyOptions

# VIDEO
@onready var screen_res_btn: CheckButton = $BG/M/V/VideoOptions/M/Options/H1/CheckButton
@onready var check_icon: TextureRect = $BG/M/V/VideoOptions/M/Options/H1/CheckButton/CheckIcon

var default_settings: Dictionary = {
	"audio_all": 100,
	"audio_sfx": 70,
	"audio_music": 50,
	"audio_menu": 50,
	"fullscreen": false 
}

func _ready():
	$BG/M/V/HeadBG/Label.add_theme_color_override("font_color", GameManager.COLORS.lightgreen_text)
	self._reset_panels()
	self._set_current_audio_values()
	self.key_btn.disabled = true
	#self.video_btn.disabled = true
	self.hide()

func _reset_panels():
	self.audio_panel.show()
	self.video_panel.hide()
	self.key_panel.hide()

func _update_audio_all():
	var value = self.audio_all_slider.value
	var old_value = AudioServer.get_bus_volume_db(0)
	if value == old_value:
		return
	AudioServer.set_bus_volume_db(0, value)
	print("[!] Options: All audio volume set to: %s" % value)

func _update_audio_music():
	var value = self.audio_music_slider.value
	var old_value = AudioServer.get_bus_volume_db(1)
	if value == old_value:
		return
	AudioServer.set_bus_volume_db(1, value)
	print("[!] Options: Music audio volume set to: %s" % value)

func _update_audio_sfx():
	var value = self.audio_sfx_slider.value
	var old_value = AudioServer.get_bus_volume_db(2)
	if value == old_value:
		return
	AudioServer.set_bus_volume_db(2, value)
	print("[!] Options: SFX audio volume set to: %s" % value)

func _update_audio_menu():
	var value = self.audio_menu_slider.value
	var old_value = AudioServer.get_bus_volume_db(3)
	if value == old_value:
		return
	AudioServer.set_bus_volume_db(3, value)
	print("[!] Options: Menu audio volume set to: %s" % value)

func _set_current_audio_values():
	var all = AudioServer.get_bus_volume_db(0)
	var music = AudioServer.get_bus_volume_db(1)
	var sfx = AudioServer.get_bus_volume_db(2)
	var menu = AudioServer.get_bus_volume_db(3)
	self.audio_all_label.text = "%d DB" % int(all)
	self.audio_music_label.text = "%d DB" % int(music)
	self.audio_sfx_label.text = "%d DB" % int(sfx)
	self.audio_menu_label.text = "%d DB" % int(menu)
	self.audio_all_slider.value = all
	self.audio_menu_slider.value = menu
	self.audio_music_slider.value = music
	self.audio_sfx_slider.value = sfx

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
	if self.audio_panel.visible:
		self._update_audio_all()
		self._update_audio_menu()
		self._update_audio_music()
		self._update_audio_sfx()
		self._reset_panels()
		
	if GameManager.on_main_menu:
		GameManager.main_menu.anim_player.play_backwards("menu-option")
	else:
		self.hide()

func _on_back_btn_button_up():
	if GameManager.on_main_menu:
		GameManager.main_menu.anim_player.play_backwards("menu-option")
	else:
		self.hide()

func _on_sfx_slider_value_changed(value):
	audio_sfx_label.text = "%s DB" % floor(value)

func _on_music_slider_value_changed(value):
	audio_music_label.text = "%s DB" % floor(value)

func _on_menu_slider_value_changed(value):
	audio_menu_label.text = "%s DB" % floor(value)

func _on_all_audio_slider_value_changed(value):
	audio_all_label.text = "%s DB" % floor(value)

func _on_audio_btn_button_up():
	_show_audio_panel()
	
func _on_video_btn_button_up():
	_show_video_panel()
	
func _on_key_btn_button_up():
	_show_key_panel()


# screen size button
func _on_check_button_button_up():
	if screen_res_btn.button_pressed:
		default_settings['fullscreen'] = true
		check_icon.visible = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		default_settings['fullscreen'] = false
		check_icon.visible = false 
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


