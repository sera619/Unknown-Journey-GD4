extends NinePatchRect
class_name NoticeMessage

@export var item_bg: Texture
@export var quest_bg: Texture
@export var yellow_bg: Texture
@onready var timer: Timer = $Timer
@onready var label: RichTextLabel = $MarginContainer/Label

func _ready():
	timer.connect("timeout", self.queue_free)


func _set_bg(img: Texture):
	self.texture = img
	self.patch_margin_left = 64
	self.patch_margin_top = 16
	self.patch_margin_right = 64
	self.patch_margin_bottom = 16

func set_item_get_msg(item: String, amount: int):
	self._set_bg(item_bg)
	label.parse_bbcode("[center][color=orange]Gegenstand erhalten[/color]\n\n[color=white]%sx %s[/color][center]" % [amount, item])
	self.show()
	timer.start()

func set_quest_finish_msg(questname: String):
	self._set_bg(quest_bg)
	label.parse_bbcode("[center][color=orange]Quest bereit zum abgeben[/color]\n[color=white]\"%s\"[/color][/center]" % questname)
	self.show()
	timer.start()

func set_quest_update_msg(questname: String, amount: int, max_amount: int):
	self._set_bg(yellow_bg)
	label.parse_bbcode("[center][color=orange]Questfortschritt[/color]\n[color=white]\"%s\"[/color]\n[color=green]%s / %s[/color][/center]" % [questname, amount, max_amount])
	self.show()
	timer.start()

func set_quest_complete_msg(questname: String):
	self._set_bg(quest_bg)
	label.parse_bbcode("[center][color=orange]Quest abgeschlossen\n[/color]\n[color=white]\"%s\"[/color][/center]" % questname)
	self.show()
	timer.start()

func set_quest_new_msg(questname: String):
	self._set_bg(quest_bg)
	label.parse_bbcode("[center][color=orange]Neue Quest erhalten:\n\n[/color][color=white]\"%s\""% questname)
	self.show()
	timer.start()
