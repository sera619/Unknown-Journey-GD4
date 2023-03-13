extends Control
class_name StatHUD

@onready var healthbar = $VBoxContainer/HealthBar
@onready var energiebar = $VBoxContainer/EnergieBar
var maximum_health
var maximum_energie

func _ready():
	EventHandler.connect("player_maxhealth_changed", update_max_health)
	EventHandler.connect("player_maxenergie_changed", update_max_energie)
	EventHandler.connect("player_health_changed", update_health)
	EventHandler.connect("player_energie_changed", update_energie)

func update_health(health):
	healthbar.value = health

func update_max_health(max_health):
	healthbar.max_value = max_health 

func update_energie(energie):
	energiebar.value = energie

func update_max_energie(max_energie):
	energiebar.max_value = max_energie
