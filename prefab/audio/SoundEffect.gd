extends Node
class_name SoundEffect


func _ready():
	self.playing = true
	self.connect("finished",queue_free)

