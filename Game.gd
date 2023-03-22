extends Node
class_name Game


@export_enum("Normal", "Development") var run_type: int
@onready var world_holder = $WorldHolder

var player: Player
var loaded_data = null
var new_game: bool = false
var change_player_spawn_location: bool = false


const LevelScenes: Dictionary = {
	"MainMenu": preload("res://prefab/UI/MainMenu.tscn"),
	"WorldBase": preload("res://world/WorldBase.tscn"),
	"SmallCave": preload("res://world/SmallCave.tscn"),
	"Wood": preload("res://world/Wood.tscn"),
	"SwordCave": preload("res://world/SwordCave.tscn"),
	"Grasland": preload("res://world/Grasland.tscn"),
	"Hills": preload("res://world/Hills.tscn"),
	"GraslandHouse": preload("res://world/GraslandHouse.tscn"),
	"GameIntro": preload("res://prefab/UI/GameIntro.tscn")
}
const TELEPORT_SPAWN_LOCATIONS: Dictionary = {
	"GraslandHouse": Vector2(1281, 246),
}

func _ready():
	GameManager.register_node(self)
	if GameManager.player:
		player = GameManager.player
	match run_type:
		0:
			switch_gamelevel("GameIntro")
		1:
			load_game()

func start_new_game():
	QuestManager.reset_quests()
	new_game = true
	switch_gamelevel("Grasland")

func load_game():
	GameManager.load_game = true
	QuestManager.reset_quests()
	self.loaded_data = GameManager.load_savegame()
	switch_gamelevel(loaded_data['cur_world'])


func switch_gamelevel(levelname: String):
	if levelname not in LevelScenes:
		printerr("[X] Game: Scene: %s not found!" % levelname)
		return
	if world_holder.get_child_count() > 0:
		world_holder.get_child(0).call_deferred("queue_free")
	if levelname == "MainMenu" or levelname == "GameIntro":
		GameManager.on_main_menu = true
		GameManager.interface.stat_hud.hide()
		GameManager.interface.potion_panel.hide()
		GameManager.interface.exp_hud.hide()
		QuestManager.reset_quests()
		GameManager.player = null
		GameManager.interface.dot_hud.hide()
	else:
		GameManager.on_main_menu = false
		GameManager.interface.stat_hud.show()
		GameManager.interface.potion_panel.show()
		GameManager.interface.exp_hud.show()
		GameManager.interface.dot_hud.show()
	if not new_game:
		self.loaded_data = GameManager.load_savegame()
	var node = LevelScenes[str(levelname)].instantiate()
	world_holder.call_deferred("add_child",node)
	print("[!] Game: Scene - %s successfully loaded!" % levelname)



