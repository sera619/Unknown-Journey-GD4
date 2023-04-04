extends Control
class_name LoadMenu

@export var profile_slot_scene: PackedScene
@onready var profile_container = $BG/M/V/ScrollContainer/V

func _initialize_loadmenu():
	var profiles = D._load_all_player_char_data()
	for profile in profiles:
		if profile != null:
			var slot: LoadSlot = profile_slot_scene.instantiate()
			profile_container.add_child(slot)
			slot._set_slot_information(profile['playername'], str(profile['level']), GameManager.get_played_time_string(profile['played_time']))
		else:
			break

func _create_btn_click_sound():
	var sound = GameManager.interface.button_click_sound.instantiate()
	self.add_child(sound)

func _reset_loadmenu():
	if not profile_container.get_child_count() > 0:
		return
	for slot in profile_container.get_children():
		slot.queue_free()

func show_loadmenu():
	_initialize_loadmenu()
	self.visible = true

func hide_loadmenu():
	_reset_loadmenu()
	self.visible = false

func _refresh_loadmenu():
	_reset_loadmenu()
	_initialize_loadmenu()

func _on_load_btn_button_up():
	_create_btn_click_sound()
	if GameManager.on_main_menu:
		_reset_loadmenu()
		GameManager.main_menu.anim_player.play("load-menu")
	else:
		self.hide_loadmenu()
