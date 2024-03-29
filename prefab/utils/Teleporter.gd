extends Node2D
class_name Teleporter

var player: Player = null
@export_enum("WorldBase",
"SmallCave",
"Wood",
"SwordCave",
"Grasland",
"GraslandHouse",
"Hills",
"City",
"CityShop",
"SmallWood",
"CityHotel",
"CityCellar",
"CityAlchemy",
"CityFarm",
"WoodCave") var teleport_location: String
@export var animated: bool

@onready var teleArea = $TeleportArea
@onready var playerDetector = $PlayerDetector
@onready var animSprite = $AnimatedSprite2D


func _ready():
	teleArea.connect("body_entered", start_teleport)
	if animated:
		playerDetector.connect("body_entered", open_portal)
		playerDetector.connect("body_exited", close_portal)
		animSprite.connect("animation_finished", animSprite_finished)
	animSprite.visible = false

func open_portal(body):
	if body.name == "Player":
		player = body
		animSprite.visible = true
		animSprite.play("open")

func start_teleport(body):
	if not body.name == "Player":
		return
	player = body
	player.velocity = Vector2.ZERO
	EventHandler.emit_signal("player_set_interact", false)
	EventHandler.connect("transition_black", teleport_player)
	EventHandler.emit_signal("start_transition")
	

func close_portal(body):
	if body.name == "Player":
		player = null
		animSprite.play("close")

func animSprite_finished():
	if animSprite.animation == "open":
		animSprite.play("loop")
	elif animSprite.animation == "loop":
		animSprite.play("close")
	else:
		animSprite.visible = false
		animSprite.stop()

func teleport_player():
	if player != null:
		GameManager.save_data()
		EventHandler.disconnect("transition_black", teleport_player)
		match teleport_location:
			"WorldBase":
				GameManager.game.switch_gamelevel(teleport_location)
			"SmallCave":
				GameManager.game.switch_gamelevel(teleport_location)
			"Wood":
				if GameManager.current_world.world_name == "WoodCave":
					GameManager.game._change_player_spawn("WoodCaveWood")
				GameManager.game.switch_gamelevel(teleport_location)
			"SwordCave":
				GameManager.game.switch_gamelevel(teleport_location)
			"Grasland":
				if GameManager.current_world.world_name == "GraslandHouse":
					GameManager.game._change_player_spawn("GraslandHouse")
				elif GameManager.current_world.world_name == "SmallWood":
					GameManager.game._change_player_spawn("WoodGrasland")
				GameManager.game.switch_gamelevel(teleport_location)
			"GraslandHouse":
				GameManager.game.switch_gamelevel(teleport_location)
			"Hills":
				GameManager.game.switch_gamelevel(teleport_location)
			"CityShop":
				GameManager.game.switch_gamelevel(teleport_location)
			"City":
				if GameManager.current_world.world_name == "CityShop":
					GameManager.game._change_player_spawn("CityShop")
				if GameManager.current_world.world_name == "CityHotel":
					GameManager.game._change_player_spawn("CityHotelCity")
				if GameManager.current_world.world_name == "CityAlchemy":
					GameManager.game._change_player_spawn("CityAlchemyCity")
				if GameManager.current_world.world_name == "CityFarm":
					GameManager.game._change_player_spawn("CityFarmCity")
				GameManager.game.switch_gamelevel(teleport_location)
			"SmallWood":
				if GameManager.current_world.world_name == "City":
					GameManager.game._change_player_spawn("CitySmallWood")
				elif GameManager.current_world.world_name == "Wood":
					GameManager.game._change_player_spawn("WoodSmallWood")
				GameManager.game.switch_gamelevel(teleport_location)
			"CityCellar":
				GameManager.game.switch_gamelevel(teleport_location)
			"CityHotel": 
				if GameManager.current_world.world_name == "CityCellar":
					GameManager.game._change_player_spawn("CityCellarCityHotel")
				GameManager.game.switch_gamelevel(teleport_location)
			"CityAlchemy":
				GameManager.game.switch_gamelevel(teleport_location)
			"CityFarm":
				GameManager.game.switch_gamelevel(teleport_location)
			"WoodCave":
				GameManager.game.switch_gamelevel(teleport_location)
		print("[!] Teleporter: Player -> %s!" % teleport_location)
