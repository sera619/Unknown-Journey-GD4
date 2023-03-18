extends NPCBase


@onready var speak_icon: Sprite2D = $Icon
var is_talking: bool = false

func _ready():
	self.speak_icon.visible = false
	if self.npc_name in GameManager.seen_npcs:
		first_seen = false
	animtree.active = true
	pick_random_state([IDLE, WANDER])

func _setup_movement_blends():
	animtree.set("parameters/Idle/blend_position", velocity)
	animtree.set("parameters/Move/blend_position", velocity)

func _physics_process(delta):
	if velocity != Vector2.ZERO:
		_setup_movement_blends()
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
		CHASE:
			chase_state(delta)
	
	move_and_slide()
	if Input.is_action_just_pressed("interact") and player_detector.player != null:
		if is_talking == true:
			return
		is_talking = true
		GameManager.dialog_box.set_speaker(self)
		if GameManager.quest_system.player_questlog[self.quest_names[0]].quest_state == Quest.QS.COMPLETE \
		and GameManager.quest_system.player_questlog[self.quest_names[1]].quest_state == Quest.QS.COMPLETE:
			if GameManager.quest_system.player_questlog[self.quest_names[2]].quest_state == Quest.QS.NOT_GIVEN:
				GameManager.dialog_box.option_a_btn.connect("button_down", activate_quest3)
				GameManager.dialog_box.set_dialog_text(GameManager.quest_system.player_questlog[self.quest_names[2]].quest_start_text)
				GameManager.dialog_box.show_dialog()
				return
			if GameManager.quest_system.player_questlog[self.quest_names[2]].quest_state == Quest.QS.ACTIVE:
				GameManager.dialog_box.set_dialog_text(GameManager.quest_system.player_questlog[self.quest_names[0]].quest_progress_text)
				GameManager.dialog_box.show_dialog()
				return
			if GameManager.quest_system.player_questlog[self.quest_names[2]].quest_state == Quest.QS.COMPLETE:
				GameManager.dialog_box.set_dialog_text("Na du? Wie gehts dir heute?")
				GameManager.dialog_box.show_dialog()
				return
		if GameManager.quest_system.player_questlog[self.quest_names[0]].quest_state == Quest.QS.NOT_GIVEN:
			GameManager.dialog_box.option_a_btn.connect("button_down", activate_quest1)
			GameManager.dialog_box.set_dialog_text(GameManager.quest_system.player_questlog[self.quest_names[0]].quest_start_text)
			GameManager.dialog_box.show_dialog()
			return
		if GameManager.quest_system.player_questlog[self.quest_names[0]].quest_state == Quest.QS.ACTIVE:
			GameManager.dialog_box.set_dialog_text(GameManager.quest_system.player_questlog[self.quest_names[0]].quest_progress_text)
			GameManager.dialog_box.show_dialog()
			return
		if GameManager.quest_system.player_questlog[self.quest_names[0]].quest_state == Quest.QS.FINISHED:
			GameManager.dialog_box.option_a_btn.connect("button_down", finish_quest1)
			GameManager.dialog_box.set_dialog_text(GameManager.quest_system.player_questlog[self.quest_names[0]].quest_complete_text)
			GameManager.dialog_box.show_dialog()
			return
		if GameManager.quest_system.player_questlog[self.quest_names[0]].quest_state == Quest.QS.COMPLETE:
			if GameManager.quest_system.player_questlog[self.quest_names[1]].quest_state == Quest.QS.NOT_GIVEN:
				GameManager.dialog_box.option_a_btn.connect("button_down", activate_quest2)
				GameManager.dialog_box.set_dialog_text(GameManager.quest_system.player_questlog[self.quest_names[1]].quest_start_text)
				GameManager.dialog_box.show_dialog()
				return
			if GameManager.quest_system.player_questlog[self.quest_names[1]].quest_state == Quest.QS.ACTIVE:
				GameManager.dialog_box.set_dialog_text(GameManager.quest_system.player_questlog[self.quest_names[1]].quest_progress_text)
				GameManager.dialog_box.show_dialog()
				return
			if GameManager.quest_system.player_questlog[self.quest_names[1]].quest_state == Quest.QS.FINISHED:
				GameManager.dialog_box.option_a_btn.connect("button_down", finish_quest2)
				GameManager.dialog_box.set_dialog_text(GameManager.quest_system.player_questlog[self.quest_names[1]].quest_complete_text)
				GameManager.dialog_box.show_dialog()
				return
			
func activate_quest1():
	GameManager.dialog_box.option_a_btn.disconnect("button_down", activate_quest1)
	give_quest("Das Schwert")


func activate_quest2():
	GameManager.dialog_box.option_a_btn.disconnect("button_down", activate_quest2)
	give_quest("Ungeziefer")
	
func activate_quest3():
	GameManager.dialog_box.option_a_btn.disconnect("button_down", activate_quest3)
	give_quest(quest_names[2])

func finish_quest1():
	GameManager.dialog_box.option_a_btn.disconnect("button_down", finish_quest1)
	GameManager.quest_system._complete_quest("Das Schwert")
	GameManager.player.stats.has_sword = true


func finish_quest2():
	GameManager.dialog_box.option_a_btn.disconnect("button_down", finish_quest2)
	GameManager.quest_system._complete_quest("Ungeziefer")

func chase_state(delta):
	var player = player_detector.player
	if player != null:
		if global_position.distance_to(player.global_position) <= 8 or global_position.distance_to(player.global_position) >= 64:
			accelerate_towards_point(player.global_position, delta)
		else:
			state = IDLE
	else:
		state = IDLE

func seek_player():
	var player: Player = null
	if player_detector.can_see_player():
		player = player_detector.player
		if global_position.distance_to(player.global_position) <= 8 or global_position.distance_to(player.global_position) >= 64:
			state = CHASE
		else:
			state = IDLE
	else:
		if player and player_detector.player == null:
			player = null
		return

func wander_state(delta):
	seek_player()
	if wander_controller.get_time_left() == 0:
		update_wander()
	accelerate_towards_point(wander_controller.target_position, delta)
	if global_position.distance_to(wander_controller.target_position) <= 4:
		update_wander()

func idle_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if wander_controller.get_time_left() == 0:
		update_wander()
	seek_player()
	if player_detector.can_see_player():
		state = CHASE
