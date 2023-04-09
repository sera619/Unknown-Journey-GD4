extends Control
class_name MicroMenu

@onready var pause_btn: TextureButton =$H/MenuBox/PauseBtn
@onready var char_btn: TextureButton = $H/MenuBox/CharBtn
@onready var inv_btn: TextureButton =$H/MenuBox/InventoryBtn
@onready var quest_btn: TextureButton =$H/MenuBox/QuestBtn
@onready var menu_btn: TextureButton =$H/MenuBtn
@onready var menu_panel: HBoxContainer =$H/MenuBox

var i: Interface = null

func _ready():
	i = GameManager.interface


func _show_micromenu():
	menu_panel.show()

func _hide_micromenu():
	menu_panel.hide()

func _create_btn_click_sound():
	var sound = GameManager.interface.button_click_sound.instantiate()
	self.add_child(sound)

func _on_quest_btn_button_down():
	i = GameManager.interface
	_create_btn_click_sound()
	if not i.qlog.visible:
		i.qlog.show_log()
	else:
		i.qlog.hide_log()

func _on_inventory_btn_button_down():
	i = GameManager.interface
	_create_btn_click_sound()
	_hide_micromenu()
	if not i.inventory_panel.visible:
		i.inventory_panel.show_inventory()
	else:
		i.inventory_panel.hide_inventory()

func _on_char_btn_button_down():
	i = GameManager.interface
	_create_btn_click_sound()
	_hide_micromenu()
	if not i.charpanel.visible:
		i.charpanel.show_charpanel()
	else:
		i.charpanel.hide_charpanel()

func _on_pause_btn_button_down():
	i = GameManager.interface
	_create_btn_click_sound()
	_hide_micromenu()
	if not i.pausmenu.visible:
		i.pausmenu.showpause()
	else:
		i.pausmenu.hidepause()

func _on_menu_btn_button_down():
	_create_btn_click_sound()
	if not menu_panel.visible:
		self._show_micromenu()
	else:
		self._hide_micromenu() 


func _on_save_btn_button_down():
	_create_btn_click_sound()
	_hide_micromenu()
	GameManager.save_data()
	GameManager.info_box.set_info_text("[center][color=green]Information[/color]\n\n[color=red]Dein Spiel wurde gespeichert![/color][/center]")
