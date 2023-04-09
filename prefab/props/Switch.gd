extends Node2D
class_name Switch

@export var object_path: NodePath
@export var click_sound_scene: PackedScene
@export_enum("Light", "Door", "Fire") var switch_type: int
@onready var player_detector = $PlayerDetector
@onready var icon = $Icon
@onready var body = $Body

var object = null
@export var is_on: bool = false

func _ready():
	if is_on:
		body.frame = 1
	else:
		body.frame = 0
	if object_path:
		object = get_node(object_path)

func _switch_on():
	_create_sound()
	is_on = true
	body.frame = 1
	match switch_type:
		0:
			get_tree().call_group("world_light", "_light_on")
		2:
			if object == null:
				return
			object._light_on()
	
	print("[Switch]: Switch \"%s\" turned \"on\"" % self.name)

func _switch_off():
	_create_sound()
	is_on = false
	body.frame = 0
	match switch_type:
		0:
			get_tree().call_group("world_light", "_light_off")
		2:
			if object == null:
				return
			object._light_off()
	print("[Switch]: Switch \"%s\" turned \"off\"" % self.name)

func _create_sound():
	var sound = click_sound_scene.instantiate()
	self.add_child(sound)

func _process(_delta):
	if not player_detector.can_see_player():
		if icon.visible:
			icon.visible = false
		return
	if not icon.visible:
		icon.visible = true
	if Input.is_action_just_pressed("interact"):
		if is_on:
			_switch_off()
		else:
			_switch_on()
