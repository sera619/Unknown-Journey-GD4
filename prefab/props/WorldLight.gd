extends Node2D
class_name WorldLight


@export var light_energy: float = 0.25
@onready var light: Light2D = $PointLight2D
@export var animated: bool
@export var color: Color
@onready var sprite = $Body

func _ready():
	if animated:
		sprite.play("default")
	light.enabled = false
	light.color = color
	light.energy = light_energy

func _light_on():
	light.enabled = true

func _light_off():
	light.enabled = false
