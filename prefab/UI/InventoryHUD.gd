extends Control
class_name InventoryHUD

@onready var panel_header: Label = $BG/M/V/Header/Label
@onready var item_list: ItemList = $BG/M/V/H/ItemList
@onready var item_header: Label = $BG/M/V/H/InfoPanel/M/V/Name
@onready var item_des: Label = $BG/M/V/H/InfoPanel/M/V/Des
@onready var item_amount: Label = $BG/M/V/H/InfoPanel/M/V/Amount
@onready var item_type: Label = $BG/M/V/H/InfoPanel/M/V/Type


func _ready():
	_reset_item_information()
	panel_header.add_theme_color_override("font_color", GameManager.COLORS.lightgreen_text)
	item_type.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	item_header.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	item_des.add_theme_color_override("font_color", GameManager.COLORS.blue_text)
	item_amount.add_theme_color_override("font_color", GameManager.COLORS.green_text)

func hide_inventory():
	self._reset_item_information()
	self.hide()

func show_inventory():
	self._update_inventory_hud()
	self.show()

func _update_inventory_hud():
	var count = 0
	item_list.clear()
	for item in InventoryManager.current.get_children():
		item_list.add_item(item.item_name, item.item_icon)
		item_list.set_item_tooltip_enabled(count, false)
		count += 1

func _reset_item_information():
	item_amount.text = ""
	item_type.text = ""
	item_header.text = ""
	item_des.text = ""

func _on_item_list_item_selected(index):
	item_list.deselect_all()
	item_list.select(index)
	var item_name = item_list.get_item_text(index) 
	var item: Item = InventoryManager.get_item_information(item_name)
	if item:
		item_header.text = str(item.item_name)
		item_des.text = str(item.item_description)
		if item.item_type == "Consumable":
			item_type.text = str("Benutzbar")
		item_amount.text = "%s / %s" % [item.item_amount, item.item_max_amount]

func _on_ok_btn_button_up():
	self.hide_inventory()

func _on_item_list_empty_clicked(_at_position, _mouse_button_index):
	self._reset_item_information()
	item_list.deselect_all()
