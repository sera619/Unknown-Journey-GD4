extends NPCBase


@onready var speak_icon: Sprite2D = $Icon
var is_talking: bool = false
var start_position: Vector2 = Vector2.ZERO

func _ready():
	start_position = global_position
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
	if Input.is_action_just_pressed("interact") and player_detector.can_see_player() and not is_talking:
		is_talking = true
		dialog_handler()


func dialog_handler():
	var dialog: DialogBox = GameManager.dialog_box
	dialog.set_speaker(self)
	
	# check if quest is availbe 
	if not QuestManager.current_quest and QuestManager.is_quest_availble("Mein Haus"):
		# start quests
		if QuestManager.is_quest_availble("Das Schwert") and QuestManager.is_quest_availble("Ungeziefer"):
			QuestManager.activate_quest("Das Schwert")
			var quest: Quest = QuestManager.current_quest
			dialog.set_dialog_text(quest.start_text)
			dialog.show_dialog()
		elif not QuestManager.is_quest_availble("Das Schwert") and QuestManager.is_quest_availble("Ungeziefer"):
			QuestManager.activate_quest("Ungeziefer")
			var quest: Quest = QuestManager.current_quest
			dialog.set_dialog_text(quest.start_text)
			dialog.show_dialog()
		elif not QuestManager.is_quest_availble("Ungeziefer") and QuestManager.is_quest_availble("Mein Haus"):
			QuestManager.activate_quest("Mein Haus")
			var quest: Quest = QuestManager.current_quest
			dialog.set_dialog_text(quest.start_text)
			dialog.show_dialog()
		
	elif QuestManager.current_quest:
		var quest: Quest = QuestManager.current_quest
		#Quest 1 routine
		if quest.title == "Das Schwert":
			match quest.state:
				Quest.QS.ACTIVE:
					dialog.set_dialog_text(quest.progress_text)
					dialog.show_dialog()
				Quest.QS.FINSIH:
					dialog.option_a_btn.connect("button_down", complete_quest_1)
					dialog.set_dialog_text(quest.complete_text)
					dialog.show_dialog()
		# Quest 2 routine
		elif quest.title == "Ungeziefer":
			match quest.state:
				Quest.QS.ACTIVE:
					dialog.set_dialog_text(quest.progress_text)
					dialog.show_dialog()
				Quest.QS.FINSIH:
					dialog.option_a_btn.connect("button_down", complete_quest_1)
					dialog.set_dialog_text(quest.complete_text)
					dialog.show_dialog()
		elif quest.title == "Mein Haus":
			match quest.state:
				Quest.QS.ACTIVE:
					dialog.set_dialog_text(quest.progress_text)
					dialog.show_dialog()
				Quest.QS.FINSIH:
					dialog.option_a_btn.connect("button_down", complete_quest_1)
					dialog.set_dialog_text(quest.complete_text)
					dialog.show_dialog()
	else:
		dialog.set_dialog_text("Hallo, wie geht es dir heute?")
		dialog.show_dialog()

func complete_quest_1():
	GameManager.dialog_box.option_a_btn.disconnect("button_down", complete_quest_1)
	if QuestManager.current_quest.title == "Das Schwert":
		GameManager.player.stats.has_sword = true
		InventoryManager.add_equip("Schwert")
		InventoryManager._equip_item("Schwert")
		GameManager.player.set_sprite(1)
		GameManager.current_world.info_trigger.queue_free()
		GameManager.interface.newskill_hud.set_skill_text("Normaler Angriff", "Du hast ein\n\nSchwert gefunden.\n\nDu kannst jetzt\n\nnormale Angriffe ausführen.\n\nDrücke die Taste \"Space\"!")
	QuestManager.current_quest.complete()


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
