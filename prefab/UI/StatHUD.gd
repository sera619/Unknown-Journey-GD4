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
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(healthbar, "value", health, 1.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(tween.kill)
	#healthbar.value = health
	#tween.interpolate_value(healthbar.value, health, 2.0, 2.0 , Tween.TRANS_LINEAR,Tween.EASE_IN_OUT)

func update_max_health(max_health):
	healthbar.max_value = max_health 

func update_energie(energie):
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(energiebar, "value", energie, 1.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(tween.kill)
	
func update_max_energie(max_energie):
	energiebar.max_value = max_energie
