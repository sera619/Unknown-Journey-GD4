extends Control


@onready var energiepot_amount = $BG/M/H/EnergiePots/AmountLabel
@onready var healthpot_amount = $BG/M/H/HealthPots/AmountLabel

func _ready():
	self.visible = false
	EventHandler.connect("player_get_energiepot", update_energiepot)
	EventHandler.connect("player_get_healthpot", update_healthpot)

func update_healthpot(new_value):
	healthpot_amount.text = "%s" % new_value

func update_energiepot(new_value):
	energiepot_amount.text = "%s" % new_value

