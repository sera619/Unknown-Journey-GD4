extends Node2D


@onready var particle = $CPUParticles2D


func _ready():
	EventHandler.connect("stop_rain", _stop_rain)
	particle.emitting = true

func _stop_rain():
	self.queue_free()
