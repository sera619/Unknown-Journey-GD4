extends NinePatchRect
class_name LoadSlot

@onready var namelabel = $M/H/NameLabel
@onready var levellabel = $M/H/LevelLabel
@onready var del_slot_btn = $M/H/H/DelBtn
@onready var load_slot_btn = $M/H/H/LoadBtn

var slot_playername: String

func _ready():
	del_slot_btn.connect("button_up", _delete_slot)
	load_slot_btn.connect("button_up", _load_slot)

func _set_slot_information(playername: String, playerlevel: String):
	slot_playername = playername
	namelabel.text="%s" % playername
	levellabel.text ="%s" % playerlevel

func _delete_slot():
	print("Slotdel clicked")
	D._delete_profile(slot_playername)
	if GameManager.on_main_menu:
		GameManager.main_menu.loadpanel._refresh_loadmenu()
	else:
		GameManager.interface.load_menu._refresh_loadmenu()

func _load_slot():
	var data = D._load_profile_char_data(slot_playername)
	GameManager.selected_playername = slot_playername
	GameManager.game._load_profile_game(data)