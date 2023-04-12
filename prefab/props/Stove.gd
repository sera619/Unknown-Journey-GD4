extends AnimatedLight

@onready var audio_player = $AudioStreamPlayer2D

func _light_on():
	var tween = get_tree().create_tween()
	light.enabled = true
	light.color = self.color
	tween.tween_property(light, "energy", self.light_energy, self.light_fade_time).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(tween.kill)
	audio_player.playing = true
	sprite.play("on")

func _light_off():
	var tween = get_tree().create_tween()
	tween.tween_property(light, "energy", self.min_energy, self.light_fade_time).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(self._disable_light)
	tween.tween_callback(tween.kill)

func _disable_light():
	sprite.play("off")
	audio_player.playing = false
	light.enabled = false
	
