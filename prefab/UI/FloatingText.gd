extends RichTextLabel
class_name FloatingText

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	anim_player.connect("animation_finished", _kill)

func _set_dmg_value(value:int, color: Color, left: bool):
	self.add_theme_color_override("default_color", color)
	self.parse_bbcode("[center][wave amp=40 freq=10]\n\n-%s[/wave][/center]" % str(value))
	if left:
		anim_player.play("float_left")
	else:
		anim_player.play("float_right")


func _set_heal_value(value:int, color: Color, left: bool):
	self.add_theme_color_override("default_color", color)
	self.parse_bbcode("[center][wave amp=40 freq=10]\n\n+%s[/wave][/center]" % str(value))
	if left:
		anim_player.play("float_left")
	else:
		anim_player.play("float_right")

func _set_energie_value(value:int, color: Color, left: bool):
	self.add_theme_color_override("default_color", color)
	self.parse_bbcode("[center][wave amp=40 freq=10]\n\n+%s[/wave][/center]" % str(value))
	if left:
		anim_player.play("float_left")
	else:
		anim_player.play("float_right")


func _kill(anim_name):
	if anim_name != "float_left" or anim_name != "float_right":
		return
	self.call_deferred("queue_free")
