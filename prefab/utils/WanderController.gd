extends Node2D
class_name WanderController

@export var wander_range: int = 32

@onready var start_pos = self.global_position
@onready var target_position = self.global_position
@onready var wander_timer: Timer = $WanderTimer

var target_vector: Vector2

func _ready():
	randomize()
	update_target_position()

func update_target_position():
	target_vector = Vector2(randf_range(-wander_range, wander_range), randf_range(-wander_range, wander_range))
	target_position = start_pos + target_vector

func get_time_left():
	return wander_timer.time_left

func start_wander_timer(duration:int):
	wander_timer.start(duration)
