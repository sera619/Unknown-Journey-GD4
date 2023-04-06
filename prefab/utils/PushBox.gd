extends CharacterBody2D
class_name PhysicBox

var push_speed = 120
var push_vector = Vector2()
var friction = 200
var ACCELERATION = 500
var can_pushed = false

func _push(vel):
	velocity = vel


func _physics_process(delta):
	if velocity != Vector2.ZERO:
		velocity = velocity.move_toward(push_vector * push_speed, 65 * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 50 * delta)
	
	if get_slide_collision_count() <= 0:
		velocity = velocity.move_toward(Vector2.ZERO, 50 * delta)
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity

