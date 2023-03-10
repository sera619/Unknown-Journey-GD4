extends CharacterBody2D
class_name NPCBase

@export_category('NPC Settings')
@export var npc_name: String
@export_enum("Normal-NPC", "Quest-NPC") var npc_type: String

@export_category('NPC Movement')
@export	var move_speed: int 
@export var acceleration: int
@export var friction: int

@onready var animplayer = $AnimationPlayer
@onready var animtree = $AnimationTree 
@onready var animstate = animtree.get("parameters/playback")
@onready var wander_controller: WanderController = $WanderController
@onready var player_detector: PlayerDetector = $PlayerDetector

enum {
	WANDER,
	IDLE,
	CHASE,
	TALK
}
var state = IDLE

func _setup_movement_blends():
	pass

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(randi_range(1, 3))

func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * move_speed, acceleration * delta)
