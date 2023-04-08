extends Node2D
class_name AnimatedLight

@export var light_energy: float = 0.25
@export var light_fade_time: float 
@onready var light: Light2D = $PointLight2D
@export var color: Color
@onready var sprite = $Body

var min_energy: float = 0.0

func _light_on():
	var tween = get_tree().create_tween()
	light.enabled = true
	light.color = self.color
	tween.tween_property(light, "energy", self.light_energy, self.light_fade_time).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(tween.kill)
	sprite.play("on")

func _light_off():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", self.min_energy, self.light_fade_time).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(self._disable_light)
	tween.tween_callback(tween.kill)

func _disable_light():
	sprite.play("off")
	light.enabled = false
	
