extends Control
class_name DeathScreen


@onready var animplayer = $AnimationPlayer
@export var death_music_scene: PackedScene
var end = false

func _ready():
	self.visible = false
	EventHandler.connect("player_died", show_screen)

func show_screen():
	self.visible = true
	var sound = death_music_scene.instantiate()
	get_tree().current_scene.add_child(sound)
	animplayer.play("show")

func hide_screen():
	self.visible = false
	animplayer.play_backwards("show")

func _on_ok_btn_button_down():
	EventHandler.connect("transition_black", _revive)
	EventHandler.emit_signal("start_transition")

func _revive():
	EventHandler.disconnect("transition_black", _revive)
	GameManager.current_world.revive_player()
	hide_screen()

func _go_menu():
	hide_screen()
	EventHandler.disconnect("transition_black", _go_menu)
	GameManager.game.switch_gamelevel("MainMenu")

func _on_back_btn_button_down():
	EventHandler.connect("transition_black", _go_menu)
	EventHandler.emit_signal("start_transition")
