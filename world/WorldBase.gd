extends Node
class_name WorldBase

@export_category('Base Information')
@export var world_name: String

@onready var maputils = $Map/GameMap/MapUtils
@onready var npc_container = $Map/GameObjects/NPC
@onready var enemy_container = $Map/GameObjects/Enemys
@onready var entry_spot = $Map/EntrySpot
@onready var player_scene = preload("res://prefab/player/Player.tscn")
@onready var game_map = $Map/GameObjects

func _ready():
	_on_ready()
	
func _on_ready():
	spawn_player()
	GameManager.register_node(self)

func get_entry_spot():
	if entry_spot:
		return entry_spot.global_position

func spawn_player():
	if GameManager.player != null:
		GameManager.player.queue_free()
		GameManager.player = null
	var new_player:Player = player_scene.instantiate()
	game_map.add_child(new_player)
	new_player.global_position = get_entry_spot()

func respawn_player():
	var new_player:Player = player_scene.instantiate()
	game_map.add_child(new_player)
	new_player.global_position = get_entry_spot()
