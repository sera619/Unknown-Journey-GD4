extends PhysicBox
class_name SwitchBox

@onready var active_area: Area2D = $Area2D
@export var locked: bool
@onready var body: Sprite2D = $Body


func _ready():
	
	active_area.connect("area_entered", _lock_box)

func _physics_process(delta):
	if not locked:
		if velocity != Vector2.ZERO:
			velocity = velocity.move_toward(push_vector * push_speed, 65 * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, 50 * delta)
		
		if get_slide_collision_count() <= 0:
			velocity = velocity.move_toward(Vector2.ZERO, 50 * delta)
		set_velocity(velocity)
		move_and_slide()
		velocity = velocity

func _lock_box(area):
	if not area.is_in_group("switchPlattform"):
		return
	self.global_position = area.global_position
	self.global_position.y += 6
	locked = true
	body.frame = 1
	get_parent()._puzzle_on()
