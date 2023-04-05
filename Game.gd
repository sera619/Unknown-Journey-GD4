extends Node
class_name Game

@export_category("Development Options")
@export_enum("Normal", "Development") var run_type: int
@export_enum("None", "MainMenu", "Hills", "Wood", "Grasland", "GraslandHouse","SwordCave", "City", "CityShop", "SmallWood") var dev_start_map: String
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
	"City": preload("res://world/City.tscn"),
	"CityShop": preload("res://world/CityShop.tscn"),
	"GraslandHouse": preload("res://world/GraslandHouse.tscn"),
	"GameIntro": preload("res://prefab/UI/GameIntro.tscn"),
	"SmallWood": preload("res://world/SmallWood.tscn")
}
const TELEPORT_SPAWN_LOCATIONS: Dictionary = {
	"GraslandHouse": Vector2(1281, 246),
	"WoodGrasland": Vector2(-349, 149),
	"CityShop": Vector2(-1041, 164),
	"WoodSmallWood": Vector2(-673, 271),
	"CitySmallWood": Vector2(225, 595)
}

var teleport_spawn_location: Vector2 = Vector2.ZERO
var world_shadow = null

func _development_start():
	new_game = true
	GameManager.selected_playername = "Sera"
	if dev_start_map == "None":
		load_game()
	else:
		switch_gamelevel(dev_start_map)

func _process(delta):
	G.delta = delta

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
	InventoryManager.reset_items()
	D._reset_unique_data()
	new_game = true
	switch_gamelevel("Grasland")

func load_game():
	GameManager.load_game = true
	QuestManager.reset_quests()
	InventoryManager.reset_items()
	self.loaded_data = GameManager.load_savegame()
	switch_gamelevel(loaded_data['cur_world'])

func _load_profile_game(data):
	GameManager.load_game = true
	QuestManager.reset_quests()
	InventoryManager.reset_items()
	self.loaded_data = data
	D._load_unique_open_data(self.loaded_data['playername'])
	switch_gamelevel(self.loaded_data['cur_world'])

func _on_show_world_shadow():
	if world_shadow != null:
		world_shadow.queue_free()
		world_shadow = null
		print("[!] Game: Shadow removed!")
	var shadow = world_shadow_scene.instantiate()
	GameManager.current_world.map_container.add_child(shadow)
	GameManager.current_world.map_container.move_child(shadow, shadow.get_index()-1)
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
	if levelname == "MainMenu" or levelname == "GameIntro":
		GameManager.on_main_menu = true
		GameManager.interface.stat_hud.hide()
		GameManager.interface.potion_panel.hide()
		GameManager.interface.exp_hud.hide()
		QuestManager.reset_quests()
		GameManager.player = null
		GameManager.interface.dot_hud.hide()
		GameManager.interface.micro_menu.hide()
		GameManager.current_world = null
	else:
		GameManager.on_main_menu = false
		GameManager.interface.stat_hud.show()
		GameManager.interface.potion_panel.show()
		GameManager.interface.exp_hud.show()
		GameManager.interface.dot_hud.show()
		GameManager.interface.micro_menu.show()
	if not new_game:
		self.loaded_data = D._load_profile_char_data(GameManager.selected_playername)
	if world_holder.get_child_count() > 0:
		if GameManager.current_world:
			if GameManager.current_world.get_node_or_null("Map/CanvasModulate") != null:
				var canvas_node = GameManager.current_world.get_node("Map/CanvasModulate")
				canvas_node.get_parent().remove_child(canvas_node)
		world_holder.get_child(0).call_deferred("queue_free")
	var node = LevelScenes[str(levelname)].instantiate()
	world_holder.call_deferred("add_child",node)
	print("[!] Game: Scene - %s successfully loaded!" % levelname)

func _change_player_spawn(location: String):
	match location:
		"WoodGrasland":
			self.teleport_spawn_location = self.TELEPORT_SPAWN_LOCATIONS[str(location)]
		"GraslandHouse":
			self.teleport_spawn_location = self.TELEPORT_SPAWN_LOCATIONS[str(location)]
		"CityShop":
			self.teleport_spawn_location = self.TELEPORT_SPAWN_LOCATIONS[str(location)]
		"CitySmallWood":
			self.teleport_spawn_location = self.TELEPORT_SPAWN_LOCATIONS[str(location)]
		"WoodSmallWood":
			self.teleport_spawn_location = self.TELEPORT_SPAWN_LOCATIONS[str(location)]
	self.change_player_spawn_location = true
	print("[!] Game: Change player spawn @ %s" % location)

