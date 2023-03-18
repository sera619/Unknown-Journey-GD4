extends Node

var player: Player = null
var camera: GameCamera = null
var current_world: WorldBase = null
var game: Game = null
var interface: Interface = null
var dialog_box: DialogBox = null
var info_box: InfoBox = null
var ui_questlog = null
var on_main_menu: bool = false
var seen_npcs = []
var quest_system: QuestSystem = null


func register_node(node: Node):
	if node.name == "Player":
		player = node
		print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "GameCamera":
		camera = node
		print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.is_in_group("WorldBase"):
		current_world = node
		print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "Game":
		game = node
		print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "Interface":
		interface = node
		print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "Questlog":
		ui_questlog = node
		print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "DialogBox":
		dialog_box = node
		print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "InfoBox":
		info_box = node
		print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "QuestSystem":
		quest_system = node
		print("[!] GameManager: Node: %s registered!" % node.name)
	else:
		print("[!] GameManager: Cant register: %s" % node.name)


func save_data(playername=""):
	var savepath = "user://savegame.save"
	if playername != "":
		savepath = "user://%s-savegame.save" % playername
	var savegame = FileAccess.open(savepath, FileAccess.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for node in save_nodes:
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue
		
		var node_data = node.call("save")
			
		var json_string = JSON.stringify(node_data)
		savegame.store_line(json_string)
	print("[!] Data: Savegame successfully saved!")

func load_savegame(playername=""):
	var loadpath = "user://savegame.save" 
	if playername != "":
		loadpath = "user://%s-savegame.save" % playername
	if not FileAccess.file_exists(loadpath):
		return 
	var save_game = FileAccess.open(loadpath, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		var node_data = json.get_data()
		return node_data


func load_game():
	if not FileAccess.file_exists("user://savegame.save"):
		return # Error! We don't have a save to load.
	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()
		
	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		
	# Creates the helper class to interact with JSON
		var json = JSON.new()
		
		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
			
		# Get the data from the JSON object
		var node_data = json.get_data()
		return node_data
#		# Firstly, we need to create the object and add it to the tree and set its position.
#		var new_object = load(node_data["filename"]).instantiate()
#		get_node(node_data["parent"]).add_child(new_object)
#		#new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
#		
#		# Now we set the remaining variables.
#		for i in node_data.keys():
#			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
#				continue
#			new_object.set(i, node_data[i])
