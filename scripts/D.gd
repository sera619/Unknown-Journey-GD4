extends Node

const user_path: String = "user://profiles/"

var default_hotkey_settings: Dictionary = {
	"attack":32,
	"bomb":51,
	"charpanel":67,
	"combatmode":70,
	"dash":86,
	"debug_key":4194332,
	"devconsole":4194336,
	"dialog_key":4194333,
	"double_attack":81,
	"energiepotion":50,
	"healthpotion":49,
	"heavy_attack":82,
	"hook":52,
	"interact":69,
	"inventory":73,
	"menu":4194305,
	"move_down":83,
	"move_left":65,
	"move_right":68,
	"move_up":87,
	"qlog":76,
	"run":4194325,
	"testaction":4194443
}

var hotkey_settings: Dictionary = {
	
}

var unique_open_data = {
	"Grasland":[
		
	],
	"SmallWood": [
		
	],
	"City":[
		
	],
	"Wood":[
		
	],
	"CityCellar": [
		
	],
	"CityHotel": [
		
	],
	"Hills": [
		
	]
}

func _reset_unique_data():
	unique_open_data = {
	"Grasland":[
		
	],
	"SmallWood": [
		
	],
	"City":[
		
	],
	"Wood":[
		
	],
	"CityCellar": [
		
	],
	"CityHotel": [
		
	],
	"Hills": [
		
	]
}


func _save_unique_open_data(playername: String):
	if not _check_profile_exists(playername):
		_create_profile_directory(playername)
	var save_path = "user://profiles/%s/uniquesavegame.save" % playername
	var json_string = JSON.stringify(unique_open_data)
	var save_data = FileAccess.open(save_path, FileAccess.WRITE)
	save_data.store_line(json_string)
	print("[Data]: Unique-Opensavegame from player \"%s\" saved in profiles!" % playername)

func _load_unique_open_data(playername: String):
	if not _check_profile_exists(playername):
		return
	var loadpath = "user://profiles/%s/uniquesavegame.save" % playername
	if not FileAccess.file_exists(loadpath):
		return
	var unique_save = FileAccess.open(loadpath, FileAccess.READ)
	while unique_save.get_position() < unique_save.get_length():
		var json_string = unique_save.get_line()
		var json = JSON.new()
		var result = json.parse(json_string)
		if not result == OK:
			print("[Data]: Unique-Savegame from player \"%s\" is corrupted!" % playername) 
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var unique_data = json.get_data()
		self.unique_open_data = unique_data
	print("[Data]: Unique-Savegame from player \"%s\" loaded from profiles." % playername)

func _load_profile_quest_data(playername: String):
	if not _check_profile_exists(playername):
		return
	var loadpath = "user://profiles/%s/questsavegame.save" % playername
	if not FileAccess.file_exists(loadpath):
		return
	
	var quest_save = FileAccess.open(loadpath, FileAccess.READ)
	while quest_save.get_position() < quest_save.get_length():
		var json_string = quest_save.get_line()
		var json = JSON.new()
		var result = json.parse(json_string)
		if not result == OK:
			print("[Data]: Quest-Savegame from player \"%s\" is corrupted!" % playername) 
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var quest_data = json.get_data()
		return quest_data

func _load_profile_char_data(playername: String):
	if not _check_profile_exists(playername):
		return
	var loadpath = "user://profiles/%s/savegame.save" % playername
	if not FileAccess.file_exists(loadpath):
		return
	var char_save = FileAccess.open(loadpath, FileAccess.READ)
	while char_save.get_position() < char_save.get_length():
		var json_string = char_save.get_line()
		var json = JSON.new()
		var result = json.parse(json_string)
		if not result == OK:
			print("[Data]: Character-Savegame from player \"%s\" is corrupted!" % playername) 
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var char_data = json.get_data()
		return char_data

func _save_profile_quest_data(playername: String):
	if not _check_profile_exists(playername):
		_create_profile_directory(playername)
	var save_path = "user://profiles/%s/questsavegame.save" % playername
	var quest_list = []
	for quest in QuestManager.current.get_children():
		var quest_data: Dictionary = {
			"title": quest.title,
			"state": quest.state,
			"amount": quest.current_amount
		}
		quest_list.append(quest_data)
	var data = {
		'current_quest': QuestManager.current_quest.title if QuestManager.current_quest else "",
		'quest_list': quest_list
	}
	var json_string = JSON.stringify(data)
	var quest_save = FileAccess.open(save_path, FileAccess.WRITE)
	quest_save.store_line(json_string)
	print("[Data]: Quest-Savegame from player \"%s\" saved in profiles!" % playername)

func _save_profile_char_data(playername: String):
	if not _check_profile_exists(playername):
		_create_profile_directory(playername)
	var savepath = "user://profiles/%s/savegame.save" % playername
	var savegame = FileAccess.open(savepath, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		var node_data = node.call("save")
			
		var json_string = JSON.stringify(node_data)
		savegame.store_line(json_string)
	
	print("[Data]: Char-Savegame from player \"%s\" saved in profiles!" % playername)

func _save_profile_inventory_data(playername: String):
	if not _check_profile_exists(playername):
		_create_profile_directory(playername)
	var savepath = "user://profiles/%s/inventorysavegame.save" % playername
	var inventory_list: Array = []
	var equip_list: Array = []
	
	for item in InventoryManager.current.get_children():
		var item_data = {
			"name": item.item_name,
			"amount": item.item_amount,
		}
		inventory_list.append(item_data)
	
	for equip in InventoryManager.current_equip.get_children():
		var equip_data = {
			"name": equip.item_name,
			"equipped": equip.item_equipped
		}
		equip_list.append(equip_data)
		
	var data = {
		"inv_list": inventory_list,
		"equip_list": equip_list
	}
	var json_string = JSON.stringify(data)
	var itemsave = FileAccess.open(savepath, FileAccess.WRITE)
	itemsave.store_line(json_string)
	print("[Data]: Inventory-Savegame from player \"%s\" saved in profiles!" % playername)


func _load_profile_inventory_data(playername: String):
	if not _check_profile_exists(playername):
		return
	var loadpath = "user://profiles/%s/inventorysavegame.save" % playername
	if not FileAccess.file_exists(loadpath):
		return
	
	var inventory_save = FileAccess.open(loadpath, FileAccess.READ)
	while inventory_save.get_position() < inventory_save.get_length():
		var json_string = inventory_save.get_line()
		var json = JSON.new()
		var result = json.parse(json_string)
		if not result == OK:
			print("[Data]: Inventory-Savegame from player \"%s\" is corrupted!" % playername) 
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var inventory_data = json.get_data()
		return inventory_data


func _load_hotkey_profile():
	var file = FileAccess.open("user://actiondict.save", FileAccess.READ)
	while file.get_position() < file.get_length():
		var j_string = file.get_line()
		var j = JSON.new()
		var result = j.parse(j_string)
		var content = j.get_data()
		return content
	#hotkey_settings = content
	#print(hotkey_settings)

func _save_hotkey_profile(data):
	var json_string = JSON.stringify(data)
	var file = FileAccess.open("user://actiondict.save", FileAccess.WRITE)
	file.store_line(json_string)
	print('[Data]: Hotkey-Profile saved!')

func _reset_hotkey_profile():
	_save_hotkey_profile(default_hotkey_settings)
	hotkey_settings = _load_hotkey_profile()
	for k in hotkey_settings.keys():
		var e = InputEventKey.new()
		e.keycode = int(D.hotkey_settings[k])
		e.physical_keycode = int(D.hotkey_settings[k])
		e.pressed = true
		InputMap.action_erase_events(str(k))
		InputMap.action_add_event(str(k), e)

func _setup_hotkey_profile():
	if not FileAccess.file_exists("user://actiondict.save"):
		_save_hotkey_profile(default_hotkey_settings)
		hotkey_settings = _load_hotkey_profile()
	else:
		hotkey_settings = _load_hotkey_profile()
		for k in hotkey_settings.keys():
			var e = InputEventKey.new()
			e.keycode = int(D.hotkey_settings[k])
			e.physical_keycode = int(D.hotkey_settings[k])
			e.pressed = true
			InputMap.action_erase_events(str(k))
			InputMap.action_add_event(str(k), e)
		
func _delete_profile(playername: String):
	if not _check_profile_exists(playername):
		return
	DirAccess.remove_absolute("user://profiles/%s/questsavegame.save" % playername)
	DirAccess.remove_absolute("user://profiles/%s/savegame.save" % playername)
	DirAccess.remove_absolute("user://profiles/%s/inventorysavegame.save" % playername)
	DirAccess.remove_absolute("user://profiles/%s/uniquesavegame.save" % playername)
	DirAccess.remove_absolute("user://profiles/%s" % playername)
	print("[Data]: Saveprofile from player \"%s\" deleted!" % playername)


func _load_all_player_char_data() -> Array:
	var profile_names = _get_all_player_profile_names()
	var loaded_data: Array = []
	if profile_names.is_empty():
		return loaded_data
	for playername in profile_names:
		var player_char_data = _load_profile_char_data(playername)
		loaded_data.append(player_char_data)
	return loaded_data

func _get_all_player_profile_names() -> Array:
	var list = []
	var dir = DirAccess.open(user_path)
	#var count: int = 0
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				#print("[Data]: Found profile: %s" % file_name)
				list.append(file_name)
				#count += 1
			file_name = dir.get_next()
	#print("[Data]: %sx Profilenames found" % count)
	return list

func _check_profile_exists(playername: String) -> bool:
	if DirAccess.dir_exists_absolute(user_path + playername):
		return true
	return false

func _create_profile_directory(playername: String):
	if DirAccess.dir_exists_absolute(user_path+playername):
		print("[Data]: Profile %s already exists!" % playername)
		return
	DirAccess.make_dir_absolute(user_path+playername)

func _setup_profiles():
	if not DirAccess.dir_exists_absolute(user_path):
		DirAccess.make_dir_absolute(user_path)
		print("[Data]: No Profile-directory found, create new.")

func _delete_old_save_files():
	for n in _get_all_player_profile_names():
		_delete_profile(n)
		print("[Data]: Old files from player \"%s\" deleted!" % n) 
	if FileAccess.file_exists("user://savegame.save"):
		DirAccess.remove_absolute("user://savegame.save")
	if FileAccess.file_exists("user://questsavegame.save"):
		DirAccess.remove_absolute("user://questsavegame.save")
	if FileAccess.file_exists("user://inventorysavegame.save"):
		DirAccess.remove_absolute("user://inventorysavegame.save")


##################### GAME SETUP #####################
# Change mousecursors
func _setup_game_mouse():
	var normal_mouse = load("res://assets/UI/menu/mouse_normal.png")
	var beam_cursor = load("res://assets/UI/menu/mouse_beam.png")
	Input.set_custom_mouse_cursor(normal_mouse)
	Input.set_custom_mouse_cursor(beam_cursor,Input.CURSOR_IBEAM)
	Input.set_custom_mouse_cursor(beam_cursor,Input.CURSOR_DRAG)
	Input.set_custom_mouse_cursor(normal_mouse,Input.CURSOR_POINTING_HAND)
	




