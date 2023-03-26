extends MoveBehaviour
class_name AIChase

func _get_steering(obj: AIData, target: AIData = G.player_data) -> SteeringData:
	steering = SteeringData.new()
	
	distance = obj.pos.distance_to(target.pos)
	var target_speed = speed
	
	if distance <= MIN_RANGE_TO_TARGET:
		return null
	
	target_velocity = obj.pos.direction_to(target.pos) * target_speed
	steering.linear = target_velocity
	return steering
