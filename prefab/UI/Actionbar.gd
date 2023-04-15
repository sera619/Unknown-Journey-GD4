extends Control
class_name Actionbar

@onready var button_container = $H
@onready var healthpot_btn = $H/HealthpotBtn
@onready var energiepot_btn = $H/EnergiepotBtn
@onready var dash_btn = $H/DashBtn
@onready var attack_btn = $H/AttackBtn
@onready var double_attack_btn = $H/DoubleAttackBtn
@onready var heavy_attack_btn = $H/HeavyAttackBtn
@onready var bomb_btn = $H/BombBtn


func _ready():
	EventHandler.connect("player_inventory_item_changed", _update_items)
	EventHandler.connect("actionbar_disable", _disable_bar)
	EventHandler.connect("actionbar_enable", _enable_bar)
	EventHandler.connect("player_level_changed", _enable_slot)


func _enable_slot(level):
	if level > 1:
		dash_btn.visible = true
	else:
		dash_btn.visible = false
		
	if level > 3:
		double_attack_btn.visible = true
		energiepot_btn.visible = true
	else:
		double_attack_btn.visible = false
		energiepot_btn.visible = false

		
	if level > 7:
		heavy_attack_btn.visible = true
	else:
		heavy_attack_btn.visible = false

func reset_bar():
	energiepot_btn.visible = false
	dash_btn.visible = false
	attack_btn.visible = false
	double_attack_btn.visible = false
	heavy_attack_btn.visible = false
	bomb_btn.visible = false


func _enable_bar():
	for button in button_container.get_children():
		if not button.visible:
			continue
		button.disabled = false

func _disable_bar():
	for button in button_container.get_children():
		if not button.visible:
			continue
		button.disabled = true

func _update_items(item: Item):
	match item.item_name:
		"Heiltrank":
			healthpot_btn.get_node("ItemAmoun").text = "%s" % item.item_amount
			if item.item_amount == 0:
				healthpot_btn.get_node("CDProgress").modulate = Color(0.33000001311302, 0.33000001311302, 0.33000001311302)
			else:
				healthpot_btn.get_node("CDProgress").modulate = Color(1, 1, 1)
		"Energietrank":
			energiepot_btn.get_node("ItemAmoun").text = "%s" % item.item_amount
			if item.item_amount == 0:
				energiepot_btn.get_node("CDProgress").modulate = Color(0.33000001311302, 0.33000001311302, 0.33000001311302)
			else:
				energiepot_btn.get_node("CDProgress").modulate = Color(1, 1, 1)
		"Bombe":
			bomb_btn.get_node("ItemAmoun").text = "%s" % item.item_amount
			if item.item_amount == 0:
				bomb_btn.get_node("CDProgress").modulate = Color(0.33000001311302, 0.33000001311302, 0.33000001311302)
			else:
				bomb_btn.get_node("CDProgress").modulate = Color(1, 1, 1)
