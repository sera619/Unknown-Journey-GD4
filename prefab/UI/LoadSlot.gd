extends NinePatchRect
class_name LoadSlot

@export var popup_scene: PackedScene

@onready var namelabel = $M/H/NameLabel
@onready var levellabel = $M/H/LevelLabel
@onready var del_slot_btn = $M/H/H/DelBtn
@onready var load_slot_btn = $M/H/H/LoadBtn
@onready var timelabel = $M/H/ZeitLabel

var slot_playername: String


func _ready():
	del_slot_btn.connect("pressed", _delete_slot_pressed)
	load_slot_btn.connect("pressed", _load_slot)

func _create_btn_click_sound():
	var sound = GameManager.interface.button_click_sound.instantiate()
	self.add_child(sound)

func _set_slot_information(playername: String, playerlevel: String, played_time: String):
	slot_playername = playername
	namelabel.text="%s" % playername
	levellabel.text ="%s" % playerlevel
	timelabel.text = "%s" % played_time

func _delete_slot_pressed():
	_create_btn_click_sound()
	var delete_message: String = "Wenn du fortfährst, werden sämtliche Profildaten unwiderruflich gelöscht!\nBist du sicher das du den Spielstand\n\n\"%s\"\n\nlöschen möchtest?" % slot_playername
	var pop: AcceptPopup = popup_scene.instantiate()
	GameManager.interface.add_child(pop)
	pop.connect("popup_accept", _delete_slot)
	pop.set_text(delete_message)
	pop.show()

func _delete_slot():
	D._delete_profile(slot_playername)
	if GameManager.on_main_menu:
		GameManager.main_menu.loadpanel._refresh_loadmenu()
	else:
		GameManager.interface.load_menu._refresh_loadmenu()

func _load_slot():
	if not GameManager.on_main_menu:
		get_tree().paused = false
		print(slot_playername)
	_create_btn_click_sound()
	GameManager.selected_playername = slot_playername
	EventHandler.connect("transition_black", _load_game)
	EventHandler.emit_signal("start_transition")

func _load_game():
	var data = D._load_profile_char_data(slot_playername)
	GameManager.info_box.clear_cache()
	GameManager.game._load_profile_game(data)
	GameManager.interface.pausmenu.visible = false
	GameManager.interface.load_menu.hide_loadmenu()

