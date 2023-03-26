extends Node
class_name WorldBase

@export_category('Base Information')
@export var world_name: String

@onready var maputils = $Map/GameMap/MapUtils
@onready var npc_container = $Map/GameObjects/NPC
@onready var enemy_container = $Map/GameObjects/Enemys
@onready var entry_spot = $Map/EntrySpot
@onready var respawn_spot = $Map/RespawnSpot
@onready var player_scene = preload("res://prefab/player/Player.tscn")
@onready var game_map = $Map/GameObjects
@onready var map_container = $Map

func _ready():
	_on_ready()
	
func _on_ready():
	spawn_player()
	GameManager.register_node(self)
	if GameManager.load_game:
		QuestManager.load_quests()
		GameManager.load_game = false
	

func get_entry_spot():
	if entry_spot:
		return entry_spot.global_position

func get_respawn_spot():
	if respawn_spot:
		return respawn_spot.global_position

func revive_player():
	if GameManager.player != null:
		GameManager.player = null
	var new_player = player_scene.instantiate()
	game_map.add_child(new_player)
	new_player.global_position = get_respawn_spot()


func spawn_player():
	if GameManager.player != null:
		GameManager.player.queue_free()
		GameManager.player = null
	var new_player:Player = player_scene.instantiate()
	game_map.add_child(new_player)
	if GameManager.game.change_player_spawn_location:
		new_player.global_position = GameManager.game.teleport_spawn_locationsddddddddddaadddddddddaaaaaaaaaa
		GameManager.game.change_player_spawn_location = false
	else:
		new_player.global_position = get_entry_spot()

func respawn_player():
	var new_player:Player = player_scene.instantiate()
	game_map.add_child(new_player)
	new_player.global_position = get_entry_spot()
