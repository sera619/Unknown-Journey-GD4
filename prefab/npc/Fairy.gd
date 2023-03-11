extends NPCBase

func _ready():
	animtree.active = true
	pick_random_state([IDLE, WANDER])

func _setup_movement_blends(delta):
	animtree.set("parameters/Idle/blend_position", velocity)
	animtree.set("parameters/Move/blend_position", velocity)

func _physics_process(delta):
	if velocity != Vector2.ZERO:
		_setup_movement_blends(delta)
		animstate.travel("Move")
	else:
		animstate.travel("Idle")
	
	match state:
		IDLE:
			idle_state(delta)
		WANDER:
			wander_state(delta)
		CHASE:
			chase_state(delta)
	
	move_and_slide()
	if Input.is_action_just_pressed("interact") and player_detector.player != null and GameManager.dialog_box.visible == false:
		var seen_list = player_detector.player.stats.seen_npcs
		GameManager.dialog_box.set_speaker_name(self.npc_name)
		GameManager.dialog_box.option_b_btn.connect("button_down", cancel_pressed)
		if self.npc_name not in seen_list and first_seen:
			GameManager.dialog_box.option_a_btn.connect("button_down", okay_pressed)
			first_seen = false
			player_detector.player.stats.add_seen_npc(self.npc_name)
			GameManager.dialog_box.set_dialog_text(default_text)
			GameManager.dialog_box.show_dialog()
		elif self.quest.quest_state == Quest.QS.NOT_GIVEN and not first_seen:
			GameManager.dialog_box.option_a_btn.connect("button_down", accept_quest)
			GameManager.dialog_box.set_dialog_text(quest_start_text)
			GameManager.dialog_box.show_dialog()
		elif self.quest.quest_state == Quest.QS.ACTIVE:
			GameManager.dialog_box.set_dialog_text("Kannst du die Höhle nicht finden?")
			GameManager.dialog_box.show_dialog()
		elif self.quest.quest_state == Quest.QS.FINISHED:
			GameManager.dialog_box.option_a_btn.connect("button_down", reward_player)
			GameManager.dialog_box.set_dialog_text(quest_ready_text)
			GameManager.dialog_box.show_dialog()
		else:
			GameManager.dialog_box.set_dialog_text(quest_complete_text)
			GameManager.dialog_box.show_dialog()

func okay_pressed():
	first_seen = false
	player_detector.player.stats.add_seen_npc(self.npc_name)
	GameManager.dialog_box.option_a_btn.disconnect("button_down", okay_pressed)
	GameManager.dialog_box.option_b_btn.disconnect("button_down", cancel_pressed)

func reward_player():
	quest.complete_quest()
	quest = null

func accept_quest():
	GameManager.dialog_box.option_b_btn.disconnect("button_down", cancel_pressed)
	GameManager.dialog_box.option_a_btn.disconnect("button_down", accept_quest)
	give_quest()

func cancel_pressed():
	GameManager.dialog_box.option_b_btn.disconnect("button_down", cancel_pressed)
	print("[!] Quest NPC \"%s\": Dialog canceled!" % self.npc_name)

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
