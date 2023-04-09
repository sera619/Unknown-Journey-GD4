extends TextureButton
class_name ActionbarSlot

@onready var cd_progress = $CDProgress

func start_cooldown(cd_time: int = 1):
	var tween = create_tween()
	tween.tween_property(cd_progress, "value", 0, cd_time)
	tween.tween_callback(_reset_progress)
	tween.tween_callback(tween.kill)

func _reset_progress():
	cd_progress.value = 100
