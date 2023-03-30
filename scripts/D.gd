extends Node

const user_path: String = "user://profiles/"

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
	
	print("[Data]: Char-Savegame from player \"%s\"successfully saved!" % playername)

func _save_profile_inventory_data(playername: String):
	if not _check_profile_exists(playername):
		_create_profile_directory(playername)
	var savepath = "user://profiles/%s/inventorysavegame.save" % playername
	var inventory_list = []
	for item in InventoryManager.current.get_children():
		var item_data = {
			"name": item.item_name,
			"amount": item.item_amount,
		}
		inventory_list.append(item_data)
	var data = {
		"inv_list": inventory_list
	}
	var json_string = JSON.stringify(data)
	var itemsave = FileAccess.open(savepath, FileAccess.WRITE)
	itemsave.store_line(json_string)

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


func _delete_profile(playername: String):
	if not _check_profile_exists(playername):
		return
	DirAccess.remove_absolute("user://profiles/%s/questsavegame.save" % playername)
	DirAccess.remove_absolute("user://profiles/%s/savegame.save" % playername)
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
	var count: int = 0
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("[Data]: Found profile: %s" % file_name)
				list.append(file_name)
				count += 1
			file_name = dir.get_next()
	print("[Data]: %sx Profilenames found" % count)
	return list

func _check_profile_exists(playername: String) -> bool:
	if DirAccess.dir_exists_absolute(user_path + playername):
		return true
	return false

func _create_profile_directory(playername: String):
	if DirAccess.dir_exists_absolute(user_path+playername):
		print("[Data]: Profile %s already exists!" % playername)
	DirAccess.make_dir_absolute(user_path+playername)

func _setup_profiles():
	if DirAccess.dir_exists_absolute(user_path):
		print("[Data]: User Directory already exists!")
	else:
		DirAccess.make_dir_absolute(user_path)
		print("[Data]: User Directory created!")

