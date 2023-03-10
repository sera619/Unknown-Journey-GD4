extends Sprite2D

func _ready():
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(self,"modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(self.queue_free)
