extends Control

@onready var expbar = $Expbar


func _ready():
	EventHandler.connect("player_maxexp_changed", update_max_exp)
	EventHandler.connect("player_exp_changed", update_exp)

func update_exp(new_exp):
	var tween = get_tree().create_tween().bind_node(self)
	tween.tween_property(expbar, "value", new_exp, 1.2).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(tween.kill)
	

func update_max_exp(new_max_exp):
	expbar.max_value = new_max_exp
