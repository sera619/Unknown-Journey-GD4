extends Camera2D
class_name GameCamera

@export_category("Zoom and Shake")
@export_group('Zoom Options')
@export var zoom_speed: int = 100
@export var zoom_margin: float = 0.3
@export var zoom_min: float = 0.2
@export var zoom_max: float = 1.5
@export var zoom_factor: float = 1.0

@export_group('Shake Options')
@export var camera_move_speed: int = 50
@export var decay = 1.6  # How quickly the shaking stops [0, 1].
@export var max_offset = Vector2(50, 25)  # Maximum hor/ver shake in pixels.
@export var max_roll = 0.1  # Maximum rotation in radians (use sparingly).

@export_category("Weather Effects")
@export var rain_effect_scene: PackedScene

@export_category("NPCs to follow")
@export var follow_npc_1: NodePath
@export var follow_npc_2: NodePath

@onready var topLeft = $Limits/TopLeft
@onready var bottomRight = $Limits/BottomRight
@onready var shakeTimer = $Timer

var default_offset = offset
var is_shaking = false
var zoom_position: Vector2 = Vector2()
var player: Player = null
var shakeTween: Tween = null


var trauma = 0.0  # Current shake strength.
var trauma_power = 2  # Trauma exponent. Use [2, 3].
var follow_npc: bool = false
var npc_to_follow = null

func _ready():
	GameManager.register_node(self)
	EventHandler.connect("start_rain", _start_raining)
	self.zoom = Vector2(0.9, 0.9)
	randomize()
	#shakeTween = get_tree().create_tween().bind_node(self)
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomRight.position.y
	limit_right = bottomRight.position.x

func _start_raining():
	var rain = rain_effect_scene.instantiate()
	self.add_child(rain)


func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func _locked_door_show():
	print("Camera3D shows door")

func levelup_position():
	self.offset.y -= 32
	await get_tree().create_timer(1.5).timeout
	self.offset = default_offset

func _process(delta):
	if GameManager.player != null and not npc_to_follow:
		self.global_position = GameManager.player.global_position
	if npc_to_follow:
		self.global_position = npc_to_follow.global_position
	self.global_position.y -= 16
	if trauma:
		trauma = max(trauma - decay  * delta, 0)
		shake()
	zoom.x = lerp(zoom.x, zoom.x * zoom_factor, zoom_speed * delta)
	zoom.y = lerp(zoom.y, zoom.y * zoom_factor, zoom_speed * delta)
	
	zoom.x = clamp(zoom.x, zoom_min, zoom_max)
	zoom.y = clamp(zoom.y, zoom_min, zoom_max)

func shake():
	var amount = pow(trauma, trauma_power)
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)

func _input(event):
	if abs(zoom_position.x - get_global_mouse_position().x) > zoom_margin:
		zoom_factor = 1.0
	if abs(zoom_position.y - get_global_mouse_position().y) > zoom_margin:
		zoom_factor = 1.0
	
	if event is InputEventKey:
		if event.is_pressed():
			if event.keycode == KEY_KP_1:
				if get_node_or_null(follow_npc_1) == null:
					return
				npc_to_follow = get_node(follow_npc_1)
			elif event.keycode == KEY_KP_2:
				if get_node_or_null(follow_npc_2) == null:
					return
				npc_to_follow = get_node(follow_npc_2)
			elif event.keycode == KEY_KP_0:
				npc_to_follow = null
			elif event.keycode == KEY_KP_8:
				add_trauma(0.8)
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_factor += 0.01
				zoom_position = get_global_mouse_position()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_factor -= 0.01
				zoom_position = get_global_mouse_position()
	
# dev setting
#	if event is InputEventKey:
#		if event.is_pressed():
#			if event.keycode == KEY_O:
#				print("Key o pressed")
#				self._start_sunlight()
#				pass

