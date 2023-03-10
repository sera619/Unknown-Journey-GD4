extends Control
class_name DevPanel

@onready var health_label: Label = $P/M/V/Label
@onready var max_health_label:Label = $P/M/V/Label2
@onready var speed_label:Label = $P/M/V/Label3
@onready var damage_label:Label = $P/M/V/Label4
@onready var exp_label:Label = $P/M/V/Label5
@onready var max_exp_label:Label = $P/M/V/Label6
@onready var level_label:Label = $P/M/V/Label7
@onready var energie_label:Label = $P/M/V/Label8
@onready var max_energie_label:Label = $P/M/V/Label9



func _ready():
	EventHandler.connect("player_health_changed", update_health)
	EventHandler.connect("player_speed_changed", update_speed)
	EventHandler.connect("player_maxhealth_changed", update_max_health)
	EventHandler.connect("player_damage_changed", update_damage)
	EventHandler.connect("player_exp_changed", update_exp)
	EventHandler.connect("player_maxexp_changed", update_max_exp)
	EventHandler.connect("player_level_changed", update_level)
	EventHandler.connect("player_maxenergie_changed", update_max_energie)
	EventHandler.connect("player_energie_changed", update_energie)
	

func update_exp(experience):
	exp_label.text = "Exp: %s" %experience

func update_max_exp(max_experience):
	max_exp_label.text = "Max-Exp: %s" % max_experience

func update_level(level):
	level_label.text = "Level: %s" % level

func update_max_energie(max_energie):
	max_energie_label.text = "Max-Energie: %s" % max_energie

func update_energie(energie):
	energie_label.text = "Energie: %s" %energie

func update_health(health):
	health_label.text = "Health: %s" %health

func update_speed(speed):
	speed_label.text = "Move-Speed: %s" %speed

func update_max_health(max_health):
	max_health_label.text = "Max-Health: %s" % max_health

func update_damage(damage):
	damage_label.text = "Damage: %s" % damage
