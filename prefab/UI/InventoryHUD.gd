extends Control
class_name InventoryHUD
@export var check_icon: Texture

@onready var panel_header: Label = $BG/M/V/Header/Label
@onready var item_list: ItemList = $BG/M/V/H/ItemList
@onready var item_header: Label = $BG/M/V/H/InfoPanel/M/V/Name
@onready var item_des: Label = $BG/M/V/H/InfoPanel/M/V/Des
@onready var item_amount: Label = $BG/M/V/H/InfoPanel/M/V/Amount
@onready var item_type: Label = $BG/M/V/H/InfoPanel/M/V/Type
@onready var bag_btn: TextureButton = $BG/M/V/BBox/BagBtn
@onready var equip_btn: TextureButton = $BG/M/V/BBox/EquipBtn
@onready var bag_panel: HBoxContainer = $BG/M/V/H
@onready var equip_panel: HBoxContainer = $BG/M/V/Equip

@onready var equip_name: Label = $BG/M/V/Equip/NinePatchRect/MarginContainer/V/Name
@onready var equip_des: Label = $BG/M/V/Equip/NinePatchRect/MarginContainer/V/Des
@onready var equip_type: Label = $BG/M/V/Equip/NinePatchRect/MarginContainer/V/Type
@onready var equip_amount: Label = $BG/M/V/Equip/NinePatchRect/MarginContainer/V/Amount
@onready var equip_list: ItemList = $BG/M/V/Equip/EquipList
@onready var change_btn: TextureButton = $BG/M/V/Equip/NinePatchRect/MarginContainer/V/ChangeButton

func _ready():
	_reset_item_information()
	#equip_btn.disabled = true
	panel_header.add_theme_color_override("font_color", GameManager.COLORS.lightgreen_text)
	item_type.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	item_header.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	item_des.add_theme_color_override("font_color", GameManager.COLORS.blue_text)
	item_amount.add_theme_color_override("font_color", GameManager.COLORS.green_text)
	equip_type.add_theme_color_override("font_color", GameManager.COLORS.lightgreen_text)
	equip_name.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	equip_des.add_theme_color_override("font_color", GameManager.COLORS.blue_text)
	equip_amount.add_theme_color_override("font_color", GameManager.COLORS.green_text)
	#equip_list.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	equip_list.add_theme_color_override("font_selected_color", GameManager.COLORS.blue_text)

func hide_inventory():
	self._reset_item_information()
	self.hide()

func show_inventory():
	self._show_bag_panel()
	self._update_inventory_hud()
	self._update_equip_hud()
	self.show()

func _show_equip_panel():
	self._reset_equip_information()
	bag_btn.button_pressed = false
	equip_btn.button_pressed = true
	equip_panel.visible = true
	bag_panel.visible = false

func _show_bag_panel():
	self._reset_item_information()
	equip_btn.button_pressed = false
	bag_btn.button_pressed = true
	equip_panel.visible = false
	bag_panel.visible = true

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

# TOGGLE BUTTONS
func _on_bag_btn_toggled(button_pressed):
	if button_pressed:
		_show_bag_panel()

func _on_equip_btn_toggled(button_pressed):
	if button_pressed:
		_show_equip_panel()

func _reset_equip_information():
	self.equip_des.text= ""
	self.equip_name.text = ""
	self.equip_type.text = ""
	self.equip_amount.text = ""
	self.change_btn.visible = false


func _update_equip_hud():
	var count = 0
	equip_list.clear()
	for equip in InventoryManager.current_equip.get_children():
		equip_list.add_item(equip.item_name, equip.item_icon)
		if equip.item_equipped:
			equip_list.set_item_custom_fg_color(count, GameManager.COLORS.lightgreen_text)
		else:
			equip_list.set_item_custom_fg_color(count, GameManager.COLORS.orange_text)
		equip_list.set_item_tooltip_enabled(count, false)
		count += 1

func _on_equip_list_item_selected(index):
	equip_list.deselect_all()
	equip_list.select(index)
	var equipname = equip_list.get_item_text(index)
	var equip: Item = InventoryManager.get_equip_information(equipname)
	if equip:
		self.change_btn.visible = true
		self.equip_des.text = str(equip.item_description)
		self.equip_name.text = str(equip.item_name)
		if equip.item_equipped:
			self.equip_amount.text = "Ausgerüstet"
			self.change_btn.disabled = true
		else:
			self.change_btn.disabled = false
			self.equip_amount.text = ""
		if equip.item_type == "Equip":
			self.equip_type.text = "%s Schaden" % equip.item_damage

func _on_equip_list_empty_clicked(_at_position, _mouse_button_index):
	self._reset_equip_information()
	equip_list.deselect_all()

func _on_change_button_button_up():
	var selected = equip_list.get_selected_items()
	selected = equip_list.get_item_text(selected[0])
	#print(selected)
	InventoryManager._equip_item(selected)
	var equip: Item = InventoryManager.get_equip_information(selected)
	if equip:
		self.equip_des.text = str(equip.item_description)
		self.equip_name.text = str(equip.item_name)
		if equip.item_equipped:
			self.equip_amount.text = "Ausgerüstet"
			self.change_btn.disabled = true
		else:
			self.equip_amount.text = ""
			self.change_btn.disabled = false
		if equip.item_type == "Equip":
			self.equip_type.text = "Ausrüstung"
