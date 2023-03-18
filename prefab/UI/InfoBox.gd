extends Control
class_name InfoBox

@export var show_time: int 
@onready var text_label: RichTextLabel = $BG/M/BGText/M/Label
@onready var show_timer: Timer = $Timer

var text_cache = []

func _ready():
	text_label.text = ""
	self.visible = false
	GameManager.register_node(self)

func set_info_text(text: String):
	if text_label.text != "":
		text_cache.append(text)
	else:
		text_label.text = "[center]%s[/center]" % text 
		show_info_text()
	
func check_cache():
	if !text_cache.is_empty():
		text_label.text = text_cache.pop_front()
		show_info_text()
	else:
		return

func reset_info_text():
	text_label.text = ""

func show_info_text():
	self.visible = true
	show_timer.start(show_time)

func hide_info_text():
	self.visible = false
	reset_info_text()

func _on_timer_timeout():
	hide_info_text()
	await get_tree().create_timer(1).timeout
	check_cache()
