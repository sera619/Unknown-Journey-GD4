extends NPCBase
class_name NPCNav

@export_category("NPC Navigation")
@export var MIN_DISTANCE_TARGET: float = 4.0
@export var PATH_DISTANCE: float = 4.0
@export var MIN_WAIT_TIME: int = 2
@export var MAX_WAIT_TIME: int = 5
@export var MOVE_POINT_CONTAINER: NodePath

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var wait_timer: Timer = $Timer
@onready var icon: Sprite2D = $SpeakIcon

var wander_positions: Array = []
var is_talking:bool = false
var move_target_position: Vector2 = Vector2(-847,245)

func _ready():
	_on_ready()
	randomize()
	wait_timer.connect("timeout", _start_wander)
	nav_agent.path_desired_distance = MIN_DISTANCE_TARGET
	nav_agent.target_desired_distance = PATH_DISTANCE
	call_deferred("actor_setup")


func actor_setup():
	await get_tree().physics_frame
	_set_movement_target(move_target_position)

func _set_movement_target(pos: Vector2):
	nav_agent.target_position = pos

func _physics_process(delta):
	if velocity != Vector2.ZERO: 
		animtree.set("parameters/Move/blend_position", velocity)
		animtree.set("parameters/Cast/blend_position", velocity)
		animtree.set("parameters/Dead/blend_position", velocity)
		animtree.set("parameters/Hurt/blend_position", velocity)
		animtree.set("parameters/Heal/blend_position", velocity)
		animtree.set("parameters/Idle/blend_position", velocity)
		animstate.travel("Move")
	else:
		animstate.travel("Idle")
	
	if player_detector.can_see_player():
		icon.visible = true
	else:
		icon.visible = false
	
	match state:
		WANDER:
			_wander_state()
		IDLE:
			_idle_state()
		TALK:
			_talk_state()
	if Input.is_action_just_pressed("interact") and player_detector.can_see_player() and not is_talking:
		is_talking = true
		_talk_state()
		dialog_handler()
	move_and_slide()


func _talk_state():
	if is_talking:
		if player_detector.can_see_player():
			var player = player_detector.player
			animtree.set("parameters/Idle/blend_position", global_position.direction_to(player.global_position))
			set_velocity(Vector2.ZERO)
		else:
			state = WANDER
	else:
		state = WANDER

func dialog_handler():
	var dialog: DialogBox = GameManager.dialog_box
	dialog.set_speaker(self)
	dialog.set_dialog_text(T.get_random_greeting())
	dialog.show_dialog()

func _idle_state():
	set_velocity(Vector2.ZERO)
	if wait_timer.is_stopped():
		move_target_position = _get_next_wander_position()
		_set_waittimer()
		wait_timer.start()

func _start_wander():
	call_deferred("actor_setup")
	state = WANDER

func _wander_state():
	if nav_agent.is_navigation_finished():
		state = IDLE
		return
	if is_talking:
		state = TALK
	
	var current_agent_position: Vector2 = global_transform.origin
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	
	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * move_speed
	set_velocity(new_velocity)


func _set_waittimer():
	var time = randi_range(MIN_WAIT_TIME, MAX_WAIT_TIME)
	wait_timer.wait_time = time
	print("[NPC NAV] %s: Wait for %s seconds." % [self.npc_name, time])

func _set_wander_positions():
	var container = get_node(MOVE_POINT_CONTAINER)
	for node in container.get_children():
		wander_positions.append(node.global_position)
	print("[NPC NAV] %s: Set Wander Positions to: %s " % [self.npc_name, wander_positions])

func _get_next_wander_position():
	if wander_positions.is_empty():
		print("[NPC NAV] %s: Wander Cycle Positions empty, setup new cycle" % [self.npc_name])
		_set_wander_positions()
		wander_positions.shuffle()
	var next_pos = wander_positions.pop_front()
	print("[NPC NAV] %s: Next pos is: %s" % [self.npc_name, next_pos])
	return next_pos
