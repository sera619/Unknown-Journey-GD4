extends NPCBase

func _ready():
	pick_random_state([IDLE, WANDER])
	animtree.active = true
	
func _setup_movement_blends():
	animtree.set("parameters/Idle/blend_position", velocity)
	animtree.set("parameters/Move/blend_position", velocity)

func _physics_process(delta):
	if velocity != Vector2.ZERO:
		_setup_movement_blends()
		animstate.travel("Move")
	else:
		animstate.travel("Idle")
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
			if wander_controller.get_time_left() == 0:
				update_wander()
		WANDER:
			if wander_controller.get_time_left() == 0:
				update_wander()
			accelerate_towards_point(wander_controller.target_position, delta)
			if global_position.distance_to(wander_controller.target_position) <= 4:
				update_wander()
	move_and_slide()
