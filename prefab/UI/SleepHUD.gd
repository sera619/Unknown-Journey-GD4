extends Control
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	anim_player.connect("animation_finished", _on_animation_finished)
	EventHandler.connect("player_sleep", start_sleep)

func start_sleep():
	get_tree().paused = true
	audio_player.playing = true
	anim_player.play("start_sleep")

func _on_animation_finished(_anim_name):
	get_tree().paused = false
	GameManager.save_data()
	GameManager.interface.notice_box.show_save_notice()
