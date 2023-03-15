extends Control
class_name DeathScreen


@onready var animplayer = $AnimationPlayer


func _ready():
	self.visible = false
	EventHandler.connect("player_died", show_screen)

func show_screen():
	self.visible = true
	animplayer.play("show")

func hide_screen():
	self.visible = false
	animplayer.play_backwards("show")

func _on_ok_btn_button_down():
	hide_screen()
	GameManager.current_world.revive_player()


func _on_back_btn_button_down():
	hide_screen()
	GameManager.game.switch_gamelevel("MainMenu")
