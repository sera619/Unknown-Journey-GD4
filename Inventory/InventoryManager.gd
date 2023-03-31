extends Node

@export var available_item_list: Array[PackedScene]
@export var available_equip_list: Array[PackedScene]
@onready var current: Node = $Current
@onready var available: Node = $Available
@onready var available_equip: Node = $AvailableEquip
@onready var current_equip: Node = $CurrentEquip


const MAX_SLOTS: int = 5

func _ready():
	initialize_items()

func initialize_items():
	for item_scene in available_item_list:
		var item: Item = item_scene.instantiate()
		available.add_child(item)
		print("[Inventory]: Item \"%s\" initialized." % item.item_name)
	for equip_scene in available_equip_list:
		var equip: Item = equip_scene.instantiate()
		available_equip.add_child(equip)
		print("[Inventory]: Equip-Item \"%s\" initialized." % equip.item_name)

func get_item_information(itemname: String):
	var item = current.get_node_or_null(itemname)
	if item != null:
		return item
	return null

func has_item(itemname: String) ->bool:
	for item in current.get_children():
		if item.item_name == itemname:
			return true
	return false

func get_equip_information(equipname: String):
	var equip = current_equip.get_node_or_null(equipname)
	if equip != null:
		return equip
	return null

func has_equip(equipname: String) -> bool:
	for equip in current_equip.get_children():
		if equip.item_name == equipname:
			return true 
	return false


func reset_items():
	for item in current.get_children():
		item.reset()
		current.remove_child(item)
		available.add_child(item)
	print("[Inventory]: Items reseted!")
	for equip in current_equip.get_children():
		equip.reset()
		current_equip.remove_child(equip)
		available_equip.add_child(equip)

func add_item(itemname: String, amount: int):
	var item: Item
	if not has_item(itemname):
		if current.get_child_count() == MAX_SLOTS:
			print("[Inventory]: Inventory is full.")
			return
		print("[Inventory]: Item %s not in Inventory add new" % itemname)
		item = available.get_node(itemname)
		available.remove_child(item)
		current.add_child(item)
	item = current.get_node(itemname)
	item.item_amount += amount
	if item.item_amount > item.item_max_amount:
		item.item_amount = item.item_max_amount
	else:
		GameManager.info_box.set_info_text("[center]Du hast\n\n[color=red]%sx %s[/color]\n\nerhalten![/center]" % [amount, item.item_name])
		EventHandler.emit_signal("player_inventory_item_changed", item)
	print("[Inventory]: %sx \"%s\" (%s/%s) added to player inventory" % [amount, itemname, item.item_amount, item.item_max_amount])

func can_use_item(itemname: String) -> bool:
	for item in current.get_children():
		if item.item_name == itemname:
			if item.item_amount >= 0:
				return true
	return false

func remove_item(itemname: String, amount: int):
	var item: Item
	if not has_item(itemname):
		print("[Inventory]: Cant remove Item %s, not in Inventory." % itemname)
		return
	item = current.get_node(itemname)
	item.item_amount -= amount
	if item.item_amount == 0:
		item.item_amount = 0
		current.remove_child(item)
		available.add_child(item)
	EventHandler.emit_signal("player_inventory_item_changed", item)
	print("[Inventory]: %sx \"%s\" (%s/%s) removed from player inventory" % [amount, itemname, item.item_amount, item.item_max_amount])

func add_equip(equipname: String):
	if current_equip.get_node_or_null(equipname) != null:
		print("[Equip]: Equip-Item \"%s\" already in bag!" % equipname)
		return
	var equip: Item = available_equip.get_node(equipname)
	available_equip.remove_child(equip)
	current_equip.add_child(equip)
	equip.item_amount = 1
	GameManager.info_box.set_info_text("[center]Du hast\n\n[color=red]%sx %s[/color]\n\nerhalten![/center]" % [1, equip.item_name])
	EventHandler.emit_signal("player_inventory_equip_changed", equip)

func _equip_item(equipname: String):
	var equip: Item = current_equip.get_node(equipname)
	if equip.item_equipped:
		print("[Equip]: Item \"%s\" already equipped!" % equipname)
		return
	for equip_item in current_equip.get_children():
		if equip_item.item_equipped:
			equip_item.item_equipped = false
	equip.item_equipped = true
	GameManager.info_box.set_info_text("[center]Du hast\n\n[color=red]%s[/color]\n\nausgerüstet![/center]" %  [equip.item_name])
	EventHandler.emit_signal("player_inventory_equip_changed", equip)

func load_inventory():
	var data = D._load_profile_inventory_data(GameManager.player.stats.playername)
	if data:
		for loaded_item in data['inv_list']:
			var item: Item = available.get_node(loaded_item['name'])
			item.item_amount = loaded_item['amount']
			available.remove_child(item)
			current.add_child(item)
			EventHandler.emit_signal("player_inventory_item_changed", item)
		if data.size() > 1:
			for loaded_equip in data['equip_list']:
				var equip: Item = available_equip.get_node(loaded_equip['name'])
				equip.item_amount = 1
				available_equip.remove_child(equip)
				current_equip.add_child(equip)
				if loaded_equip['equipped'] == true:
					_equip_item(equip.item_name)
		print("[Inventory]: Inventory for Player \"%s\" loaded!" % GameManager.player.stats.playername)
