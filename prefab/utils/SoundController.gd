extends Node
class_name SoundController


@onready var move_player:  = $MoveSound
@onready var run_player: = $RunSound
@onready var impact_player:  = $ImpactPlayer 
@onready var cast_player: = $CastPlayer
@onready var attack_player: = $AttackPlayer
@onready var timer: = $Timer 

enum CONNECT_STATE {
	NONE,
	RUN,
	MOVE
}
var c_state = CONNECT_STATE.NONE


const MOVEMENT: Dictionary = {
	"Player": {
		"Move": preload("res://assets/Music and Sounds/foodsteps/HeavyDirt1.wav"),
		"Run": preload("res://assets/Music and Sounds/foodsteps/HeavyDirtRun1.wav"),
		"Attack": preload("res://assets/Music and Sounds/sword_slash.wav")
	},
	"Enemys": {
		"WingFlap": preload("res://assets/Music and Sounds/wing_fap.wav"),
		"Mushroom": preload("res://assets/Music and Sounds/foodsteps/mushroom_step.wav"),
		"Skeleton": preload("res://assets/Music and Sounds/foodsteps/skeleton_step.wav")
	},
	"NPC":{
		"Move": preload("res://assets/Music and Sounds/foodsteps/mushroom_step.wav")
	}
} 


const SPELL_CAST: Dictionary = {
	"Ice": preload("res://assets/Music and Sounds/spells/ice_cast.wav")
}

func _setup_sounds(character: String):
	match character:
		"Player":
			move_player.stream = MOVEMENT.Player.Move
			run_player.stream =	MOVEMENT.Player.Run
			attack_player.stream = MOVEMENT.Player.Attack
		"FlyingEnemy":
			move_player.stream = MOVEMENT.Enemys.WingFlap
		"Skeleton":
			move_player.stream = MOVEMENT.Enemys.Skeleton
		"NPC":
			move_player.stream = MOVEMENT.NPC.Move
			
	#print("[!] SoundController: Sound @ %s successfully loaded!" % character) 

func _play_spell_cast_sound(element):
	match element:
		SkillManager.ELEMENT.ICE:
			cast_player.stream = SPELL_CAST.Ice
	cast_player.play()

func _play_attack_sound():
	if attack_player.playing:
		attack_player.stop()
	attack_player.play()

func _play_food_sound():
	if run_player.playing:
		run_player.stop()
	move_player.play()

func _play_run_sound():
	if move_player.playing:
		move_player.stop()
	run_player.play()
