extends Node2D

@export var light_energy: float = 0.25
@onready var light: Light2D = $PointLight2D


func _ready():
	light.enabled = false
	light.energy = light_energy

func _light_on():
	light.enabled = true

func _light_off():
	light.enabled = false
