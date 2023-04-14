extends Area2D
class_name HookSpot

@export_enum("Right", "Left", "Down", "Up") var hook_position: int

@onready var hook_pos = $HookPos
@onready var collision_shape_2d = $CollisionShape2D


func _ready():
	set_hook_spot()

func set_hook_spot():
	match hook_position:
		0:
			hook_pos.position = Vector2(13, 0)
		1:
			hook_pos.position = Vector2(-13, 0)
		2:
			hook_pos.position = Vector2(0, 13)
		3:
			hook_pos.position = Vector2(0, -13)

func get_hook_position() -> Vector2:
	return hook_pos.global_position
