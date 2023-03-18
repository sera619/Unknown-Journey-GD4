extends Camera2D
class_name GameCamera

@export_group('Zoom Options')
@export var zoom_speed: int = 100
@export var zoom_margin: float = 0.3
@export var zoom_min: float = 0.2
@export var zoom_max: float = 1.5
@export var zoom_factor: float = 1.0

@export_group('Shake Options')
@export var camera_move_speed: int = 50
@export var shake_time: float = 0.4
@export var shake_limit: int = 100
@export var shake_amount: int = 0

@onready var topLeft = $Limits/TopLeft
@onready var bottomRight = $Limits/BottomRight
@onready var shakeTimer = $Timer

var default_offset = offset
var is_shaking = false
var zoom_position: Vector2 = Vector2()
var player: Player = null
var shakeTween = null



func _ready():
	GameManager.register_node(self)
	self.zoom = Vector2(0.8, 0.8)
	#shakeTween = get_tree().create_tween().bind_node(self)
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomRight.position.y
	limit_right = bottomRight.position.x

func _locked_door_show():
	print("Camera3D shows door")

func levelup_position():
	self.offset.y -= 32
	await get_tree().create_timer(1.5).timeout
	self.offset = default_offset

func _process(delta):
		
	if GameManager.player != null:
		self.global_position = GameManager.player.global_position
		self.global_position.y -= 16
	zoom.x = lerp(zoom.x, zoom.x * zoom_factor, zoom_speed * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoom_factor, zoom_speed * delta)
	
	zoom.x = clamp(zoom.x, zoom_min, zoom_max)
	zoom.y = clamp(zoom.y, zoom_min, zoom_max)
	
	if !is_shaking:
		return
	else:
		offset = Vector2(randf_range(-shake_amount, shake_amount), randf_range(shake_amount, -shake_amount)) * delta + default_offset

func _input(event):
	if abs(zoom_position.x - get_global_mouse_position().x) > zoom_margin:
		zoom_factor = 1.0
	if abs(zoom_position.y - get_global_mouse_position().y) > zoom_margin:
		zoom_factor = 1.0
		
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_factor += 0.01
				zoom_position = get_global_mouse_position()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_factor -= 0.01
				zoom_position = get_global_mouse_position()


func shake(new_shake):
	shake_amount += new_shake
	if shake_amount > shake_limit:
		shake_amount = shake_limit
	shakeTimer.wait_time = shake_time
	shakeTween.stop_all()
	is_shaking = true
	shakeTimer.start()



func _on_timer_timeout():
	is_shaking = false
	shake_amount = 0
	shakeTween.interpolate_property(self, "offset", offset, default_offset, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	shakeTween.start()
