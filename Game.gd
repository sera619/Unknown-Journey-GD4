extends Node
class_name Game

@onready var world_holder = $WorldHolder

var player: Player
var loaded_data = null
const LevelScenes: Dictionary = {
	"MainMenu": preload("res://prefab/UI/MainMenu.tscn"),
	"WorldBase": preload("res://world/WorldBase.tscn"),
	"SmallCave": preload("res://world/SmallCave.tscn"),
	"Wood": preload("res://world/Wood.tscn"),
	"SwordCave": preload("res://world/SwordCave.tscn"),
	"Grasland": preload("res://world/Grasland.tscn")
}

func _ready():
	GameManager.register_node(self)
	if GameManager.player:
		player = GameManager.player
	GameManager.ui_questlog.update_questlist()
	switch_gamelevel("MainMenu")

func start_new_game():
	switch_gamelevel("Grasland")

func load_game():
	loaded_data = GameManager.load_savegame()
	QuestManager.load_saved_quest()
	GameManager.interface.qlog.update_questlist()
	switch_gamelevel(loaded_data['cur_world'])


func switch_gamelevel(levelname: String):
	if levelname not in LevelScenes:
		printerr("[X] Game: Scene: %s not found!" % levelname)
		return
	if world_holder.get_child_count() > 0:
		world_holder.get_child(0).call_deferred("queue_free")
	var node = LevelScenes[str(levelname)].instantiate()
	world_holder.call_deferred("add_child",node)

	if levelname == "MainMenu":
		GameManager.on_main_menu = true
		GameManager.player = null
	else:
		GameManager.on_main_menu = false
	print("[!] Game: Scene - %s successfully loaded!" % levelname)



