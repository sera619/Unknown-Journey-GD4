extends Control
class_name ShopHUD


@onready var itemname_label = $Bg/M/V/H/InfoBG/M/V/Name
@onready var itemdes_label = $Bg/M/V/H/InfoBG/M/V/Des
@onready var player_item_amount_label = $Bg/M/V/H/InfoBG/M/V/PInfo/PlayerAmount
@onready var player_gold_label = $Bg/M/V/H/InfoBG/M/V/PInfo/PlayerGold
@onready var buy_amount_label =$Bg/M/V/H/InfoBG/M/V/H/V/BuyAmount
@onready var full_price_label = $Bg/M/V/H/InfoBG/M/V/H/V/FullPrice
@onready var amount_up_btn =$Bg/M/V/H/InfoBG/M/V/H/AmountUpBtn
@onready var amount_down_btn = $Bg/M/V/H/InfoBG/M/V/H/AmountDownBtn
@onready var close_btn = $Bg/M/V/HB/BackBtn
@onready var buy_btn = $Bg/M/V/HB/BuyBtn
@onready var item_list = $Bg/M/V/H/ItemList
@onready var current = $Current


var current_items: Array = []
var buy_amount: int = 1
var buy_price: int = 0


func _reset_buy_information():
	itemname_label.text = ""
	itemdes_label.text = ""
	player_item_amount_label.text = ""
	buy_amount_label.text = ""
	full_price_label.text = ""
	buy_price = 0
	buy_amount = 1

func show_shop():
	self.player_gold_label.text = "Gold: %s" % str(GameManager.player.stats.gold)
	self.buy_btn.disabled = true
	self.amount_down_btn.visible = false
	self.amount_up_btn.visible = false
	_reset_buy_information()
	self.visible = true

func hide_shop():
	for item in current.get_children():
		item.queue_free()
	self.visible = false
	_reset_buy_information()

func _on_back_btn_button_up():
	hide_shop()

func setup_shop(itemlist):
	item_list.clear()
	for item in itemlist:
		var i = item.instantiate()
		current.add_child(i)
		item_list.add_item(i.item_name, i.item_icon)
	show_shop()

func _increase_amount():
	var selected = item_list.get_selected_items()
	var item = current.get_node_or_null(item_list.get_item_text(selected[0]))
	var player_items = InventoryManager.current.get_node(item.item_name).item_amount
	if buy_amount < 11 and player_items < item.item_max_amount:
		buy_amount += 1
		buy_price += item.item_price
		full_price_label.text = "Preis: %s" % str(buy_price)
		buy_amount_label.text = "Anzahl: %sx" % str(buy_amount)

func _check_player_gold() -> bool:
	var player_gold = GameManager.player.stats.gold
	if player_gold > buy_price:
		return true
	return false

func _on_item_list_item_selected(index):
	_reset_buy_information()
	var item_name = item_list.get_item_text(index)
	var item: Item = current.get_node_or_null(item_name)
	itemname_label.text = item.item_name
	itemdes_label.text = item.item_description
	var player_items = InventoryManager.current.get_node(item.item_name).item_amount
	player_gold_label.text = "Gold: %s" % str(GameManager.player.stats.gold)
	buy_amount_label.text = "Anzahl: %sx" % str(buy_amount)
	full_price_label.text = "Preis: %s" % str(item.item_price)
	player_item_amount_label.text = "Besitz: %s/%s" % [player_items, item.item_max_amount]
	buy_price = item.item_price
	amount_down_btn.disabled = true
	self.amount_down_btn.visible = true
	self.amount_up_btn.visible = true
	if _check_player_gold():
		amount_up_btn.disabled = false
		buy_btn.disabled = false
	else:
		amount_up_btn.disabled = true
		buy_btn.disabled = true