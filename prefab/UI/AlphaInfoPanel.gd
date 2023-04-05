extends Control
class_name AlphaInformation


func _ready():
	get_tree().paused = true


func _on_texture_button_button_up():
	get_tree().paused = false
	D._delete_old_save_files()
	self.call_deferred("queue_free")
