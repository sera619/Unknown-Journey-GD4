extends Control
class_name HotkeyPopup

signal new_hotkey

@onready var info_label = $C/BG/M/V/BG/M/V/InfoLabel
@onready var key_label = $C/BG/M/V/BG/M/V/KeyLabel
@onready var ok_btn = $C/BG/M/V/H/OkBtn
@onready var back_btn = $C/BG/M/V/H/BackBtn

@onready var action_name: String = ""

var choosed_event: InputEventKey = null
var choosed_actionanme = ""
var texturenode = null
var cur_key = null

func _create_click_sound():
	var sound = GameManager.interface.button_click_sound.instantiate()
	get_tree().current_scene.add_child(sound)

func _ready():
	ok_btn.connect("pressed", set_new_hotkey)
	back_btn.connect("pressed", _kill)
	
func _set_hotkey_text(actionname: String, current_key, node):
	var text = "Bitte drücke eine\nTaste und bestätige mit \"Okay\", um\n\"%s\"\nneu zu belegen." % actionname
	info_label.text = text
	key_label.text = current_key
	cur_key = current_key
	texturenode = node
	choosed_actionanme = actionname

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			choosed_event = event
			key_label.text = str(event.as_text_key_label())

func _kill():
	_create_click_sound()
	self.call_deferred("queue_free")

func set_new_hotkey():
	_create_click_sound()
	if choosed_event == null:
		key_label.text = "Kein Key ausgewählt!"
		return
	if key_label.text == cur_key:
		self.queue_free()
	texturenode.texture = load("res://assets/UI/keyboard_single_icons/"+key_label.text.to_upper()+".png")
	match choosed_actionanme:
		"Oben":
			InputMap.action_erase_events("move_up")
			InputMap.action_add_event("move_up", choosed_event)
			var key = D.hotkey_settings.get('move_up')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "move_up":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Unten":
			InputMap.action_erase_events("move_down")
			InputMap.action_add_event("move_down", choosed_event)
			var key = D.hotkey_settings.get('move_down')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "move_down":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Rechts":
			InputMap.action_erase_events("move_right")
			InputMap.action_add_event("move_right", choosed_event)
			var key = D.hotkey_settings.get('move_right')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "move_right":
					D.hotkey_settings[k] = key
					break
			D._save_hotkey_profile(D.hotkey_settings)
		"Links":
			InputMap.action_erase_events("move_left")
			InputMap.action_add_event("move_left", choosed_event)
			var key = D.hotkey_settings.get('move_left')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "move_left":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Aktion":
			InputMap.action_erase_events("interact")
			InputMap.action_add_event("interact", choosed_event)
			var key = D.hotkey_settings.get('interact')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "interact":
					D.hotkey_settings[k] = key
					break
			D._save_hotkey_profile(D.hotkey_settings)
		"Angriff":
			InputMap.action_erase_events("attack")
			InputMap.action_add_event("attack", choosed_event)
			var key = D.hotkey_settings.get('attack')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "attack":
					D.hotkey_settings[k] = key
					break
			D._save_hotkey_profile(D.hotkey_settings)
		"CharakterHUD":
			InputMap.action_erase_events("charpanel")
			InputMap.action_add_event("charpanel", choosed_event)
			var key = D.hotkey_settings.get('charpanel')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "charpanel":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"InventarHUD":
			InputMap.action_erase_events("inventory")
			InputMap.action_add_event("inventory", choosed_event)
			var key = D.hotkey_settings.get('inventory')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "inventory":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Heiltrank":
			InputMap.action_erase_events("healthpotion")
			InputMap.action_add_event("healthpotion", choosed_event)
			var key = D.hotkey_settings.get('healthpotion')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "healthpotion":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Energietrank":
			InputMap.action_erase_events("energiepotion")
			InputMap.action_add_event("energiepotion", choosed_event)
			var key = D.hotkey_settings.get('energiepotion')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "energiepotion":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Bombe":
			InputMap.action_erase_events("bomb")
			InputMap.action_add_event("bomb", choosed_event)
			var key = D.hotkey_settings.get('bomb')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "bomb":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Doppelangriff":
			InputMap.action_erase_events("double_attack")
			InputMap.action_add_event("double_attack", choosed_event)
			var key = D.hotkey_settings.get('double_attack')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "double_attack":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Wirbelangriff":
			InputMap.action_erase_events("heavy_attack")
			InputMap.action_add_event("heavy_attack", choosed_event)
			var key = D.hotkey_settings.get('heavy_attack')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "heavy_attack":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Pause/Menü":
			InputMap.action_erase_events("menu")
			InputMap.action_add_event("menu", choosed_event)
			var key = D.hotkey_settings.get('menu')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "menu":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"QueslogHUD":
			InputMap.action_erase_events("qlog")
			InputMap.action_add_event("qlog", choosed_event)
			var key = D.hotkey_settings.get('')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "qlog":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Dash":
			InputMap.action_erase_events("dash")
			InputMap.action_add_event("dash", choosed_event)
			var key = D.hotkey_settings.get('dash')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "dash":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Rennen":
			InputMap.action_erase_events("run")
			InputMap.action_add_event("run", choosed_event)
			var key = D.hotkey_settings.get('run')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "run":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
		"Kampfmodus":
			InputMap.action_erase_events("combatmode")
			InputMap.action_add_event("combatmode", choosed_event)
			var key = D.hotkey_settings.get('combatmode')
			D.hotkey_settings = D.default_hotkey_settings.duplicate()
			key = str(choosed_event.keycode)
			for k in D.hotkey_settings.keys():
				if k == "combatmode":
					D.hotkey_settings[k] = key
					break
				
			D._save_hotkey_profile(D.hotkey_settings)
	self.call_deferred("queue_free")
