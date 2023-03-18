extends CharacterBody2D
class_name NPCBase

@export_category('NPC Settings')
@export var npc_name: String
@export_enum("Normal-NPC", "Quest-NPC") var npc_type: String

@export_category('NPC Movement')
@export	var move_speed: int 
@export var acceleration: int
@export var friction: int

@export_category('NPC Quest Settings')
@export var quest_names: Array[String]
@export_multiline var default_text: String
@export_multiline var quest_start_text: String
@export_multiline var quest_ready_text: String
@export_multiline var quest_complete_text: String

@onready var animplayer: AnimationPlayer = $AnimationPlayer
@onready var animtree: AnimationTree = $AnimationTree 
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
var first_seen:bool = true

func _setup_movement_blends():
	pass

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(randi_range(1, 3))

func pick_random_state(state_list: Array):
	state_list.shuffle()
	return state_list.pop_front()

func give_quest(questname: String):
	var quest = GameManager.quest_system.player_questlog[questname]
	if quest.quest_state == Quest.QS.NOT_GIVEN:
		GameManager.quest_system._activate_quest(questname)
		GameManager.ui_questlog.update_questlist()
		print("[!] Quest-NPC \"%s\": Add Quest \"%s\" to Questlog!" % [self.npc_name, quest.quest_name])

func accelerate_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * move_speed, acceleration * delta)

func wander_state(delta):
	if wander_controller.get_time_left() == 0:
		update_wander()
	accelerate_towards_point(wander_controller.target_position, delta)
	if global_position.distance_to(wander_controller.target_position) <= 4:
		update_wander()

func idle_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if wander_controller.get_time_left() == 0:
		update_wander()


