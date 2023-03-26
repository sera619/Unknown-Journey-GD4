extends Resource
class_name MoveBehaviour
var MIN_RANGE_TO_TARGET: int = 32
var SLOW_RADIUS: int = 56
var FLEE_STOP_RADIUS: int = 96
var speed: int = 25
var distance
var steering: SteeringData
var target_velocity: Vector2


func _get_steering(obj: AIData, target: AIData = G.player_data) -> SteeringData:
	steering = SteeringData.new()
	
	return steering
