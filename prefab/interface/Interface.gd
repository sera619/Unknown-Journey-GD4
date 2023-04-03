extends CanvasLayer
class_name Interface

@export var show_devpanel: bool
@export var dev_console_scene: PackedScene
@export var alpha_info_scene: PackedScene
var dev_console: bool = false
@onready var qlog = $Questlog
@onready var animplayer = $AnimationPlayer
@onready var pausmenu = $PauseMenu
@onready var stat_hud = $StatHUD
@onready var charpanel: CharacterPanel = $CharacterPanel
@onready var potion_panel= $PotionPanel
@onready var exp_hud = $ExpHUD
@onready var dialog_box: DialogBox = $DialogBox
@onready var newskill_hud: NewSkillHUD = $NewSkillHUD
@onready var dot_hud: DotHUD = $DotHUD
@onready var option_panel: OptionPanel = $OptionPanel
@onready var inventory_panel: InventoryHUD = $InventoryHUD
@onready var shop_panel: ShopHUD = $ShopHUD
var showinfo = true 

func _ready():
	GameManager.register_node(self)
	EventHandler.connect("start_transition", start_transition)

func _show_alphainfo():
	if not showinfo:
		return
	showinfo = false
	await get_tree().create_timer(3).timeout
	var info = alpha_info_scene.instantiate()
	self.add_child(info)

func _input(event):
	if GameManager.on_main_menu == true or self.dev_console == true:
		return
	if event.is_action_pressed("qlog"):
		if qlog.visible:
			qlog.hide_log()
		else:
			qlog.show_log()
	if event.is_action_pressed("charpanel"):
		if charpanel.visible:
			charpanel.hide_charpanel()
		else:
			charpanel.show_charpanel()
	if event.is_action_released("devconsole"):
		if not dev_console:
			dev_console = true 
			var console = dev_console_scene.instantiate()
			self.add_child(console)
		else:
			return
	if event.is_action_pressed("inventory"):
		if not inventory_panel.visible:
			inventory_panel.show_inventory()
		else:
			inventory_panel.hide_inventory()

func hide_ui():
	qlog.hide()
	stat_hud.hide()
	potion_panel.hide()
	exp_hud.hide()
	dialog_box.hide_dialog()
	dot_hud.hide()

func start_transition():
	animplayer.play("start_transition")

func transition_is_black():
	EventHandler.emit_signal("transition_black")
