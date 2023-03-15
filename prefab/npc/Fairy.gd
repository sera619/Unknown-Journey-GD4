extends NPCBase


@onready var speak_icon: Sprite2D = $Icon

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
	if Input.is_action_just_pressed("interact") and player_detector.player != null and GameManager.dialog_box.visible == false:
		GameManager.dialog_box.set_speaker_name(self.npc_name)
		GameManager.dialog_box.option_b_btn.connect("button_down", cancel_pressed)
		if first_seen:
			GameManager.dialog_box.option_a_btn.connect("button_down", okay_pressed)
			player_detector.player.stats.add_seen_npc(self.npc_name)
			GameManager.dialog_box.set_dialog_text(default_text)
			GameManager.dialog_box.show_dialog()
			return
		if not first_seen:
			if self.quest.quest_state == Quest.QS.NOT_GIVEN:
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
	else:
		return

func okay_pressed():
	first_seen = false
	player_detector.player.stats.add_seen_npc(self.npc_name)
	GameManager.dialog_box.option_a_btn.disconnect("button_down", okay_pressed)
	GameManager.dialog_box.option_b_btn.disconnect("button_down", cancel_pressed)

func reward_player():
	GameManager.dialog_box.option_a_btn.disconnect("button_down", reward_player)
	GameManager.dialog_box.option_b_btn.disconnect("button_down", cancel_pressed)
	player_detector.player.stats.has_sword = true
	player_detector.player.set_sprite(1)
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
