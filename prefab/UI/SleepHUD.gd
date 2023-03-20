extends Control
@onready var anim_player: AnimationPlayer = $AnimationPlayer


func _ready():
	anim_player.connect("animation_finished", _on_animation_finished)
	EventHandler.connect("player_sleep", start_sleep)

func start_sleep():
	get_tree().paused = true
	anim_player.play("start_sleep")

func _on_animation_finished(_anim_name):
	get_tree().paused = false
	GameManager.save_data()
	GameManager.info_box.set_info_text("[center]\n\nDein Spielstand wurde gespeichert![/center]")
