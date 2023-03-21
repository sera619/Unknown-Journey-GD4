extends Node
class_name SoundController

@export_category("Basic Sound")
@export var move_pitch: float
@export var run_pitch: float

@export_category("Sound Files")
@export_file("*.wav") var move_sound
@export_file("*.wav") var run_sound

@onready var move_player: AudioStreamPlayer = $MoveSound
@onready var run_player: AudioStreamPlayer = $RunSound 
