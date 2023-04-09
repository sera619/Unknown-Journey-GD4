extends Control
class_name AcceptPopup

signal popup_accept
signal popup_cancel

@onready var text_label = $BG/M/V/TextBG/Text
@onready var accept_btn = $BG/M/V/H/OkayBtn
@onready var back_btn = $BG/M/V/H/BackBtn

func _ready():
	accept_btn.connect("pressed", _accept_pressed)
	back_btn.connect("pressed", _cancel_pressed)

func _create_sound():
	var sound = GameManager.interface.button_click_sound.instantiate()
	self.add_child(sound)

func set_text(text: String):
		text_label.text = text 

func _accept_pressed():
	_create_sound()
	emit_signal("popup_accept")
	self.call_deferred("queue_free")

func _cancel_pressed():
	_create_sound()
	emit_signal("popup_cancel")
	self.call_deferred("queue_free")
