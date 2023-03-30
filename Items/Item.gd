extends Node
class_name Item

@export_category("Base Settings")
@export var item_name: String
@export var item_icon: Texture
@export var item_amount: int
@export var item_max_amount: int
@export_enum("Consumable", "Quest", "Equip") var item_type: String

@export_category("Inventory Settings")
@export_group("Item Text")
@export_multiline var item_description: String
@export_category("Shop Settings")
@export var item_price: int
@export var item_sellprice: int

@export_category("Consumable")
@export var item_value: int


func reset():
	item_amount = 0
