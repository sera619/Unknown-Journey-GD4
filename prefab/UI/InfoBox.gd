extends Control
class_name InfoBox

@export var show_time: int 
@onready var text_label: Label = $BG/M/BGText/M/Label
@onready var show_timer: Timer = $Timer

func _ready():
	self.visible = false
	GameManager.register_node(self)

func set_info_text(text: String):
	text_label.text = text

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
