extends NinePatchRect
class_name NoticeMessage

@export var item_bg: Texture
@export var quest_bg: Texture
@export var yellow_bg: Texture
@export var error_bg: Texture
@onready var timer: Timer = $Timer
@onready var label: RichTextLabel = $MarginContainer/Label

func _ready():
	timer.connect("timeout", self.queue_free)


func _set_bg(img: Texture):
	self.texture = img
	self.patch_margin_left = 78
	self.patch_margin_top = 28
	self.patch_margin_right = 78
	self.patch_margin_bottom = 28
	

func set_item_get_msg(item: String, amount: int):
	self._set_bg(item_bg)
	label.parse_bbcode("[center][color=orange]\n\nGegenstand erhalten[/color]\n\n[color=white]%sx %s[/color][center]" % [amount, item])
	self.show()
	timer.start()

func set_quest_finish_msg(questname: String):
	self._set_bg(quest_bg)
	label.parse_bbcode("[center][color=orange]\nQuest bereit\n\nzum abgeben[/color]\n\n[color=white]\"%s\"[/color][/center]" % questname)
	self.show()
	timer.start()

func set_quest_update_msg(questname: String, amount: int, max_amount: int):
	self._set_bg(quest_bg)
	label.parse_bbcode("[center][color=orange]\nQuestfortschritt[/color]\n\n[color=white]\"%s\"[/color]\n\n[color=green]%s / %s[/color][/center]" % [questname, amount, max_amount])
	self.show()
	timer.start()

func set_quest_complete_msg(questname: String):
	self._set_bg(quest_bg)
	label.parse_bbcode("[center][color=orange]\nQuest abgeschlossen\n[/color]\n[color=white]\"%s\"[/color][/center]" % questname)
	self.show()
	timer.start()

func set_quest_new_msg(questname: String):
	self._set_bg(quest_bg)
	label.parse_bbcode("[center][color=orange]\nNeue Quest erhalten:\n\n[/color][color=white]\"%s\""% questname)
	self.show()
	timer.start()

func set_door_locked_msg(message: String):
	self._set_bg(error_bg)
	label.parse_bbcode("[center][color=orange]\n%s[/color][/center]" % message)
	self.show()
	timer.start()

func set_save_msg():
	self._set_bg(item_bg)
	label.parse_bbcode("[center][color=orange]\nDein Spielstand\n\nwurde gespeichert![/color][/center]")
	self.show()
	timer.start()

func set_information_msg(information: String):
	self._set_bg(yellow_bg)
	label.parse_bbcode("[center][color=orange]\n%s[/color][/center]"% information)
	self.show()
	timer.start()

func set_time_msg():
	self._set_bg(item_bg)
	label.parse_bbcode("[fill][center][color=orange]\nAktuelle Uhrzeit:\n\n[/color][color=white]%s Uhr[/color][/center]" % Time.get_time_string_from_system())
	self.show()
	timer.start()

func set_waysign_msg(locationname: String):
	self._set_bg(yellow_bg)
	label.parse_bbcode("[fill][center][color=orange]\nIn diese Richtung:[/color]\n\n[color=white]\"%s\"[/color][/center]" % locationname)
	self.show()
	timer.start()
