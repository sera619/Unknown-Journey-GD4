extends Node
class_name Game

@export_category("Development Options")
@export_enum("Normal", "Development") var run_type: int
@export_enum("Hills", "Wood", "Grasland", "GraslandHouse","SwordCave") var dev_start_map: String
@onready var world_holder = $WorldHolder
@onready var world_shadow_scene = preload("res://prefab/utils/WorldShadow.tscn")


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
	"WoodGrasland": Vector2(-349, 149)
}

var teleport_spawn_location: Vector2 = Vector2.ZERO
var world_shadow = null


func _development_start():
	if dev_start_map == "":
		load_game()
	else:
		switch_gamelevel(dev_start_map)

func _ready():
	GameManager.register_node(self)
	EventHandler.connect("show_world_shadow", _on_show_world_shadow)
	if GameManager.player:
		player = GameManager.player
	match run_type:
		0:
			switch_gamelevel("GameIntro")
		1:
			_development_start()

func start_new_game():
	QuestManager.reset_quests()
	new_game = true
	switch_gamelevel("Grasland")

func load_game():
	GameManager.load_game = true
	QuestManager.reset_quests()
	self.loaded_data = GameManager.load_savegame()
	switch_gamelevel(loaded_data['cur_world'])


func _on_show_world_shadow():
	if world_shadow != null:
		world_shadow.queue_free()
		world_shadow = null
		print("[!] Game: Shadow removed!")
	var shadow = world_shadow_scene.instantiate()
	GameManager.current_world.add_child(shadow)
	world_shadow = shadow
	print("[!] Game: Shadow succesfully applied!")
	


func switch_gamelevel(levelname: String):
	if levelname not in LevelScenes:
		printerr("[X] Game: Scene: %s not found!" % levelname)
		return
	if world_shadow != null:
		world_shadow.queue_free()
		world_shadow = null
		print("[!] Game: Shadow removed!")
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

func _change_player_spawn(location: String):
	match location:
		"WoodGrasland":
			self.teleport_spawn_location = self.TELEPORT_SPAWN_LOCATIONS[str(location)]
		"GraslandHouse":
			self.teleport_spawn_location = self.TELEPORT_SPAWN_LOCATIONS[str(location)]
	self.change_player_spawn_location = true
	print("[!] Game: Change player spawn @ %s" % location)

