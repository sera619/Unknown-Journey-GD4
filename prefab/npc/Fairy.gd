extends NPCBase

func _ready():
	animtree.active = true
	pick_random_state([IDLE, WANDER])

func _setup_movement_blends():
	animtree.set("playback/Move/blendpositon", velocity)
	animtree.set("playback/Idle/blendpositon", velocity)

func _physics_process(delta):
	if velocity != Vector2.ZERO:
		_setup_movement_blends()
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
	
	if Input.is_action_just_pressed("interact") and player_detector.player != null:
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
		else:
			return

func okay_pressed():
	first_seen = false
	player_detector.player.stats.add_seen_npc(self.npc_name)
	GameManager.dialog_box.option_a_btn.disconnect("button_down", okay_pressed)
	GameManager.dialog_box.option_b_btn.disconnect("button_down", cancel_pressed)

func accept_quest():
	GameManager.dialog_box.option_b_btn.disconnect("button_down", cancel_pressed)
	GameManager.dialog_box.option_a_btn.disconnect("button_down", accept_quest)
	give_quest()

func cancel_pressed():
	GameManager.dialog_box.option_b_btn.disconnect("button_down", cancel_pressed)
	print("[!] Quest NPC \"%s\": Dialog canceled!" % self.npc_name)

