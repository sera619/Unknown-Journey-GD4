extends Control


@onready var energiepot_amount = $BG/M/H/EnergiePots/AmountLabel
@onready var healthpot_amount = $BG/M/H/HealthPots/AmountLabel

func _ready():
	self.visible = false
	EventHandler.connect("player_get_energiepot", update_energiepot)
	EventHandler.connect("player_get_healthpot", update_healthpot)
	EventHandler.connect("player_inventory_item_changed", update_potions)

func update_healthpot(new_value):
	healthpot_amount.text = "%s" % new_value

func update_energiepot(new_value):
	energiepot_amount.text = "%s" % new_value

func update_potions(item: Item):
	match item.item_name:
		"Heiltrank":
			healthpot_amount.text = "%s" % item.item_amount
		"Energietrank":
			energiepot_amount.text = "%s" % item.item_amount
