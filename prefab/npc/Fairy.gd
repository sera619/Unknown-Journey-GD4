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
