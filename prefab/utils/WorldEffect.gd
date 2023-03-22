extends Node2D
class_name WorldEffect

@onready var sun_effect = $SunlightVFX


func _set_sunlight(light):
	sun_effect.visible = light
	sun_effect.material.set("shader_parameter/is_active", light)

func _input(event):
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_O:
				print("Key o pressed")
				if sun_effect.visible:
					self._set_sunlight(false)
				else:
					self._set_sunlight(true)
