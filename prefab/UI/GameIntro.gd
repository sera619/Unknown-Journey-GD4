extends Control
class_name GameIntro

@onready var animplayer: AnimationPlayer = $AnimationPlayer
@onready var soun_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready():
	animplayer.connect("animation_finished", _on_animation_finished)
	#soun_player.play()
	#animplayer.play("start")


func _on_animation_finished(_anim_name):
	GameManager.game.switch_gamelevel("MainMenu")

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
			GameManager.game.switch_gamelevel("MainMenu")
		elif event.keycode == KEY_SPACE:
			animplayer.play("start")
			soun_player.play()
