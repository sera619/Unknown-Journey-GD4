extends MoveBehaviour
class_name AIWander

var WANDER_TIME: int = 4
var WANDER_IDLE_TIME: int = 6
var WANDER_RANGE: int = 32
var wander_pos: Vector2 = Vector2()
var timer = 0
var wait_time = 0

func _ready():
	randomize()

func _get_steering(obj: AIData, _target: AIData = G.player_data) -> SteeringData:
	steering = SteeringData.new()
	
	timer -= G.delta
	if timer <= 0:
		wander_pos = _get_random_position()
		timer = WANDER_TIME
		
	var target_speed = speed
	
	target_velocity = obj.pos.direction_to(obj.pos + wander_pos) * target_speed
	steering.linear = target_velocity
	return steering

func _get_random_position() -> Vector2:
	return Vector2(randf_range(-WANDER_RANGE, WANDER_RANGE), randf_range(-WANDER_RANGE, WANDER_RANGE))
	
