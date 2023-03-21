extends Control
class_name GameIntro

@onready var animplayer: AnimationPlayer = $AnimationPlayer

func _ready():
	animplayer.connect("animation_finished", _on_animation_finished)
	animplayer.play("start")

func _on_animation_finished(_anim_name):
	GameManager.game.switch_gamelevel("MainMenu")

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ENTER:
			GameManager.game.switch_gamelevel("MainMenu")
