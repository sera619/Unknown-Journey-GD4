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

@export_category("Consumable Settings")
@export var item_value: int

@export_category("Equip Settings")
@export var item_damage: int
@export var item_equipped: bool

@export_category("Weaponeffect Chance")
@export_enum("5%", "10%", "15%", "20%", "25%", "30%", "35%", "40%") var trigger_chance: int
@export var extra_dmg: int
@export var effect_scene: PackedScene

func reset():
	item_amount = 0
	

func _get_weapon_effect() -> bool:
	if self.trigger_chance:
		var effect_chance = randf_range(0, 100)
		match self.trigger_chance:
			0:
				if effect_chance <= 5:
					return true
				else:
					return false
			1: 
				# 10 %
				if effect_chance <= 10:
					return true
				else:
					return false
			2:
				# 15 %
				if effect_chance <= 15:
					return true
				else:
					return false
			3:
				# 20 %
				if effect_chance <= 20:
					return true
				else:
					return false
			4:
				if effect_chance <= 25:
					return true
				else:
					return false
			5:
				if effect_chance <= 30:
					return true
				else:
					return false
			6:
				if effect_chance <= 35:
					return true
				else:
					return false
			7:
				if effect_chance <= 40:
					return true
				else:
					return false
	return false
