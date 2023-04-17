extends Node2D
class_name ValueDisplay

@export var display_time: float
@export var damage_color: Color
@export var heal_color: Color
@export var energie_color: Color

@onready var heal_value = $HealValue
@onready var energy_value = $EnergyValue
@onready var dmg_value = $DmgValue

@onready var dmg_timer =$DmgValue/Timer
@onready var heal_timer = $HealValue/Timer
@onready var energie_timer = $EnergyValue/Timer

var last_energie_value = 0

func _ready():
	_setup()

func _setup():
	heal_value.add_theme_color_override("default_color", heal_color)
	dmg_value.add_theme_color_override("default_color", damage_color)
	energy_value.add_theme_color_override("default_color", energie_color)
	dmg_timer.wait_time = display_time
	heal_timer.wait_time = display_time
	energie_timer.wait_time = display_time
	heal_timer.connect("timeout", _hide_heal_value)
	dmg_timer.connect("timeout", _hide_dmg_value)
	energie_timer.connect("timeout", _hide_energie_value)

func _show_heal_value(value):
	heal_value.parse_bbcode("[center][wave amp=40 freq=10]\n\n+%s[/wave][/center]" % str(value))
	heal_timer.start()
	heal_value.show()

func _show_dmg_value(value):
	dmg_value.parse_bbcode("[center][wave amp=40 freq=10]\n\n-%s[/wave][/center]" % str(value))
	dmg_timer.start()
	dmg_value.show()

func _show_energie_value(value):
	last_energie_value = value
	energy_value.parse_bbcode("[center][wave amp=40 freq=10]\n\n+%s[/wave][/center]" % str(value))
	energie_timer.start()
	energy_value.show()

func _hide_dmg_value():
	dmg_value.parse_bbcode("")
	dmg_value.hide()

func _hide_energie_value():
	energy_value.parse_bbcode("")
	energy_value.hide()

func _hide_heal_value():
	heal_value.parse_bbcode("")
	heal_value.hide()
