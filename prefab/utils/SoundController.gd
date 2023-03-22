extends Node
class_name SoundController


@onready var move_player: AudioStreamPlayer = $MoveSound
@onready var run_player: AudioStreamPlayer = $RunSound 

const player_move_sound = "res://assets/Music and Sounds/foodsteps/HeavyDirt1.wav"
const player_run_sound = "res://assets/Music and Sounds/foodsteps/HeavyDirtRun1.wav"

func _setup_sounds(character: String):
	match character:
		"Player":
			move_player.stream = preload(player_move_sound)
			run_player.stream = preload(player_run_sound)
	print("[!] SoundController: Sound @ %s successfully loaded!" % character) 

func _play_food_sound():
	if run_player.playing:
		run_player.stop()
	move_player.play()

func _play_run_sound():
	if move_player.playing:
		move_player.stop()
	run_player.play()
