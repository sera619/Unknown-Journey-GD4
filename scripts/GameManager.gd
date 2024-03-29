extends Node

var player: Player = null
var camera: GameCamera = null
var current_world: WorldBase = null
var game: Game = null
var interface: Interface = null
var dialog_box: DialogBox = null
var info_box: InfoBox = null
var main_menu: MainMenu = null
var ui_questlog: QuestLog = null
var on_main_menu: bool = false

var seen_npcs = []
var load_game: bool = false
var new_player_name: String = ""
var selected_playername: String = ""


const COLORS: Dictionary = {
	"orange_text":Color(0.99215686321259, 0.61568629741669, 0.0274509806186),
	"green_text": Color(0, 0.79296875, 0.09632056951523),
	"blue_text": Color(0.09411764889956, 0.70196080207825, 0.96470588445663),
	"lightgreen_text": Color(0.29803922772408, 0.91764706373215, 0.36862745881081),
	"yellow_text": Color(0.96862745285034, 0.87058824300766, 0.04705882444978),
	"red_text": Color(0.96862745285034, 0.06498773396015, 0.02161309868097)
}

const DEFAULT_GAME_OPTIONS: Dictionary = {
	"audio_all":0.0,
	"audio_menu":-16.0,
	"audio_music":-26.0,
	"audio_ambiente": -14.0,
	"audio_sfx":-5.0,
	"video_brightness": 1.0,
	"video_saturation": 1.0,
	"video_contrast": 1.0,
	"musicmute": false,
	"full_mute": false,
	"fullscreen":false,
	"vsync": true
}
var current_game_options: Dictionary = {}


func _ready():
	_initial_process()

func _initial_process():
	_setup_game_settings()
	D._setup_profiles()
	D._setup_game_mouse()
	D._setup_hotkey_profile()
	
func _setup_game_settings():
	var path = "user://gameoptions.save"
	if not FileAccess.file_exists(path):
		self._save_settings(DEFAULT_GAME_OPTIONS)
	current_game_options = self._load_settings()
	if not current_game_options.has("audio_ambiente"):
		print("[!] GameManager: Optionsavefile is not on actual version. Create new.")
		self._save_settings(DEFAULT_GAME_OPTIONS)
	if not current_game_options.has("video_contrast"):
		print("[!] GameManager: Optionsavefile is not on actual version. Create new.")
		self._save_settings(DEFAULT_GAME_OPTIONS)
	current_game_options = self._load_settings()
	self._set_game_settings(current_game_options)
	print("[!] GameManager: Gameoptions setup successfully!")


func _set_game_settings(settings: Dictionary):
	_update_video_saturation(settings['video_saturation'])
	_update_video_contrast(settings['video_contrast'])
	_update_video_brightness(settings['video_brightness'])

	AudioServer.set_bus_volume_db(1, settings['audio_all'])
	AudioServer.set_bus_volume_db(5, settings['audio_music'])
	AudioServer.set_bus_volume_db(3, settings['audio_ambiente'])
	AudioServer.set_bus_volume_db(2, settings['audio_sfx'])
	AudioServer.set_bus_volume_db(4, settings['audio_menu'])
	AudioServer.set_bus_mute(5, settings['musicmute'])
	if settings['fullscreen'] == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	if settings['vsync'] == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	print("[!] GameManager: Gameoptions applied!")


func _update_video_brightness(value):
	var world_envi = get_node("/root/Game/WorldEnvironment")
	world_envi.environment.adjustment_brightness = value

func _update_video_saturation(value):
	var world_envi = get_node("/root/Game/WorldEnvironment")
	world_envi.environment.adjustment_saturation = value

func _update_video_contrast(value):
	var world_envi = get_node("/root/Game/WorldEnvironment")
	world_envi.environment.adjustment_contrast = value


func _update_audio_all(value):
	AudioServer.set_bus_volume_db(1, value)
	self.current_game_options['audio_all'] = value
	#print("[!] GameManger: All audio volume set to: %s" % value)

func _update_audio_music(value):
	AudioServer.set_bus_volume_db(5, value)
	self.current_game_options['audio_music'] = value
	#print("[!] GameManger: Music audio volume set to: %s" % value)

func _update_audio_sfx(value):
	AudioServer.set_bus_volume_db(2, value)
	self.current_game_options['audio_sfx'] = value
	#print("[!] GameManger: SFX audio volume set to: %s" % value)

func _update_audio_menu(value):
	AudioServer.set_bus_volume_db(4, value)
	self.current_game_options['audio_menu'] = value
	#print("[!] GameManger: Menu audio volume set to: %s" % value)

func _update_musik_mute(mode: bool):
	self.current_game_options['musicmute'] = mode
	AudioServer.set_bus_mute(5, mode)
	#print("[!] GameManger: Musicmute set to: %s" % mode)

func _update_audio_ambiente(value):
	AudioServer.set_bus_volume_db(3, value)
	self.current_game_options['audio_ambiente'] = value
	#print("[!] GameManger: Ambiente audio volume set to: %s" % value)

func _update_window_mode(mode: bool):
	self.current_game_options['fullscreen'] = mode
	if mode == true:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	print("[!] GameManger: Windowmode applied!")

func _update_vsync_mode(mode: bool):
	self.current_game_options['vsync'] = mode
	if mode == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		

func register_node(node: Node):
	if node.name == "Player":
		player = node
		#print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "GameCamera":
		camera = node
		#print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.is_in_group("WorldBase"):
		current_world = node
		#print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "Game":
		game = node
		#print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "Interface":
		interface = node
		#print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "Questlog":
		ui_questlog = node
		#print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "DialogBox":
		dialog_box = node
		#print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "InfoBox":
		info_box = node
		#print("[!] GameManager: Node: %s registered!" % node.name)
	elif node.name == "MainMenu":
		main_menu = node
		#print("[!] GameManager: Node: %s registered!" % node.name)
	else:
		print("[!] GameManager: Cant register: %s" % node.name)

func _save_settings(settings: Dictionary):
	var path = "user://gameoptions.save"
	var savefile = FileAccess.open(path, FileAccess.WRITE)
	var json_string = JSON.stringify(settings)
	savefile.store_line(json_string)
	print("[!] Options: Gamesetting successfully saved!")

func _load_settings():
	var loadpath = "user://gameoptions.save"
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


func save_data(playername=""):
	D._save_profile_char_data(GameManager.player.stats.playername)
	D._save_profile_quest_data(GameManager.player.stats.playername)
	D._save_profile_inventory_data(GameManager.player.stats.playername)
	D._save_unique_open_data(GameManager.player.stats.playername)
	#print("[ZEIT]: Gespielte zeit %s" % self.get_played_time_string(self.player.stats.played_time))
	print("[Data]: Savegame successfully saved!")


func get_played_time_string(time_played):
	var play_time = time_played
	var h = floor(play_time / 3600)
	play_time -= h * 3600
	var m = floor(play_time / 60)
	play_time -= m * 60
	var s = floor(play_time)
	return str(h) + ":" + str(m).lpad(2, "0") + ":" + str(s).lpad(2, "0")  


func set_player_name(player_name: String):
	if player_name == "":
		print("[X] GameManager: No Name set!")
		return
	self.new_player_name = player_name
	self.selected_playername = player_name
	print("[!] GameManager: New playername set to \"%s\"" % player_name)


func savegame_exists() -> bool:
	var loadpath = "user://savegame.save" 
	if not FileAccess.file_exists(loadpath):
		return false
	return true

func load_savegame(playername=""):
	var loadpath = "user://savegame.save" 
	if playername != "":
		loadpath = "user://%s/savegame.save" % playername
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
