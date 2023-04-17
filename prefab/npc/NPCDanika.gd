extends NPCBase

@export var MOVE_POINT_CONTAINER: NodePath
@onready var speak_icon: Sprite2D = $SpeakIcon
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

var is_talking: bool = false
var wander_positions: Array = []
var marker_container: Node2D = null
var move_target_position: Vector2 = Vector2()

func _ready():
	_on_ready()
	_set_wander_positions()
	call_deferred("actor_setup")


func actor_setup():
	await get_tree().physics_frame

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
	
	if player_detector.player != null:
		speak_icon.visible = true
	else:
		speak_icon.visible = false
	
	match state:
		IDLE:
			idle_state(delta)
		WANDER:
			wander_state(delta)
	move_and_slide()

func interact():
	if not is_talking:
		is_talking = true
		dialog_handler()
	else:
		return

func wander_state(_delta):
	if nav_agent.is_navigation_finished():
		if QuestManager.is_quest_complete("Befreiung"):
			self.queue_free()
		return
	if is_talking:
		state = IDLE
	
	var current_agent_position: Vector2 = global_transform.origin
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	
	var new_velocity: Vector2 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * move_speed
	set_velocity(new_velocity)


func dialog_handler():
	var dialog: DialogBox = GameManager.dialog_box
	dialog.set_speaker(self)
	if QuestManager.current_quest:
		var quest: Quest = QuestManager.current_quest
		if quest.title == "Danika":
			quest.add_item()
			dialog.option_a_btn.connect("button_up", _handle_quest)
			dialog.set_dialog_text(quest.complete_text)
			dialog.show_dialog()
		elif quest.title == "Befreiung":
			match quest.state:
				Quest.QS.ACTIVE:
					dialog.set_dialog_text(quest.progress_text)
					dialog.show_dialog()
				Quest.QS.FINSIH:
					dialog.option_a_btn.connect("button_up", _handle_quest)
					dialog.set_dialog_text(quest.complete_text)
					dialog.show_dialog()
	elif not QuestManager.current_quest and QuestManager.is_quest_complete("Danika"):
		if QuestManager.is_quest_availble("Befreiung"):
			QuestManager.activate_quest("Befreiung")
			var quest: Quest = QuestManager.current_quest
			dialog.set_dialog_text(quest.start_text)
			dialog.show_dialog()
	else:
		dialog.set_dialog_text(default_text)
		dialog.show_dialog()

func _idle_state():
	set_velocity(Vector2.ZERO)

func _handle_quest():
	var dialog: DialogBox = GameManager.dialog_box
	dialog.option_a_btn.disconnect("button_up", _handle_quest)
	if QuestManager.current_quest.title == "Danika":
		QuestManager.current_quest.complete()
	elif QuestManager.current_quest.title == "Befreiung":
		QuestManager.current_quest.complete()
		_set_movement_target(_get_next_wander_position())
		state = WANDER

func _get_next_wander_position():
	if wander_positions.is_empty():
		state = IDLE
		#print("[NPC NAV] %s: Wander Cycle Positions empty, setup new cycle" % [self.npc_name])
		#_set_wander_positions()
		#wander_positions.shuffle()
	var next_pos = wander_positions.pop_front()
	#print("[NPC NAV] %s: Next pos is: %s" % [self.npc_name, next_pos])
	return next_pos

func _set_wander_positions():
	var container = get_node(MOVE_POINT_CONTAINER)
	for node in container.get_children():
		wander_positions.append(node.global_position)

func _set_movement_target(pos: Vector2):
	nav_agent.target_position = pos
