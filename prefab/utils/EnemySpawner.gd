extends Node2D


@export var enemy_container: Node2D
@export var enemy_scene_one: PackedScene
@export var enemy_scene_two: PackedScene

@onready var spawn_points_one: = $SpawnPoints1
@onready var spwan_points_two: = $SpawnPoints2


func _ready():
	spawn_enemy_one()
	

func spawn_enemy_one():
	var count: int = 0
	var enemyname: String = ""
	for pos in spawn_points_one.get_children():
		var enemy:CharacterBody2D = enemy_scene_one.instantiate()
		enemy_container.add_child(enemy)
		enemy.global_position = pos.global_position
		if enemyname == "":
			enemyname = enemy.name
		count += 1 
	print("[!] EnemySpawner: Spawned: %s times Enemy: %s" % [enemyname,str(count)])
	
