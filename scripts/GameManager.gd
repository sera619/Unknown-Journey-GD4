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
var load_game: bool = false
var new_player_name: String = ""

const COLORS: Dictionary = {
	"orange_text":Color(0.99215686321259, 0.61568629741669, 0.0274509806186),
	"green_text": Color(0, 0.79296875, 0.09632056951523),
	"blue_text": Color(0.09411764889956, 0.70196080207825, 0.96470588445663),
	"lightgreen_text": Color(0.29803922772408, 0.91764706373215, 0.36862745881081)
}


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
	QuestManager.save_quests()
	
func set_player_name(player_name: String):
	if player_name == "":
		print("[X] GameManager: No Name set!")
		return
	self.new_player_name = player_name
	print("[!] GameManager: New playername set to \"%s\"" % player_name)

func savegame_exists() -> bool:
	var loadpath = "user://savegame.save" 
	if not FileAccess.file_exists(loadpath):
		return false
	return true

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
