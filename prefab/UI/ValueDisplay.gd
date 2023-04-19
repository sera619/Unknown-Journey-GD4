extends Node2D
class_name ValueDisplay


@export var damage_color: Color
@export var heal_color: Color
@export var energie_color: Color
@export var text_scene: PackedScene
@onready var heal_timer = $HealTimer
@onready var attack_timer = $AttackTimer
@onready var energie_timer = $EnergieTimer

@onready var left: bool = true

var dmg_value_cache:Array = []
var energie_value_cache: Array = []
var heal_value_cache: Array = []

func _ready():
	heal_timer.connect("timeout", _check_heal_values)
	attack_timer.connect("timeout", _check_dmg_values)
	energie_timer.connect("timeout", _check_energie_values)

func _check_dmg_values():
	if dmg_value_cache.is_empty():
		return
	_show_dmg_value(dmg_value_cache.pop_front())
	attack_timer.start()

func _check_heal_values():
	if heal_value_cache.is_empty():
		return
	_show_heal_value(heal_value_cache.pop_front())
	heal_timer.start()
	
func _check_energie_values():
	if energie_value_cache.is_empty():
		return
	_show_energie_value(energie_value_cache.pop_front())
	energie_timer.start()

func _show_heal_value(value):
	if not heal_timer.is_stopped():
		heal_value_cache.append(value)
		return
	var l: FloatingText = text_scene.instantiate()
	if not left:
		left = true
	else:
		left = false
	self.add_child(l)
	l._set_heal_value(value, heal_color, left)
	heal_timer.start()

func _show_dmg_value(value):
	if not attack_timer.is_stopped():
		dmg_value_cache.append(value)
		return
	var l: FloatingText = text_scene.instantiate()
	if not left:
		left = true
	else:
		left = false
	self.add_child(l)
	l._set_dmg_value(value, damage_color, left)
	attack_timer.start()

func _show_energie_value(value):
	if not energie_timer.is_stopped():
		energie_value_cache.append(value)
		return
	var l: FloatingText = text_scene.instantiate()
	if not left:
		left = true
	else:
		left = false
	self.add_child(l)
	l._set_energie_value(value, energie_color, left)
	energie_timer.start()
