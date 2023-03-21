extends Control
class_name NamePopup

@onready var infolabel = $BG/M/TextBG/M/V/V/InfoLabel
@onready var nameinput:LineEdit = $BG/M/TextBG/M/V/V/NameInput
@onready var headerlabel = $BG/M/TextBG/M/V/Header


func _onready():
	self.visible = false
