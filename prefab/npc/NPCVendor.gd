extends NPCBase
class_name NPCVendor

@export_category("Items")
@export var item_list: Array[PackedScene]
@onready var icon: Sprite2D = $SpeakIcon
@onready var interaction_zone = $InteractionZone
var is_talking: bool = false


func _ready():
	_on_ready()

func _physics_process(_delta):
	if velocity != Vector2.ZERO: 
		animtree.set("parameters/Move/blend_position", velocity)
		animtree.set("parameters/Cast/blend_position", velocity)
		animtree.set("parameters/Dead/blend_position", velocity)
		animtree.set("parameters/Hurt/blend_position", velocity)
		animtree.set("parameters/Heal/blend_position", velocity)
#		animtree.set("parameters/Idle/blend_position", velocity)
		animstate.travel("Move")
	else:
		animstate.travel("Idle")
	
	if player_detector.can_see_player():
		animtree.set("parameters/Idle/blend_position", player_detector.player.global_position)
		icon.visible = true
	else:
		icon.visible = false

func interact():
	if not is_talking:
		is_talking = true
		dialog_handler()
	else:
		return

func dialog_handler():
	var dialog: DialogBox = GameManager.dialog_box
	dialog.set_speaker(self)
	dialog.option_a_btn.connect("button_up", open_shop)
	dialog.set_dialog_text("Hallo mein Freund!\nMöchtest du etwas kaufen?")
	dialog.show_dialog()

func open_shop():
	var dialog: DialogBox = GameManager.dialog_box
	dialog.option_a_btn.disconnect("button_up", open_shop)
	GameManager.interface.shop_panel.setup_shop(item_list, self)

func close_shop():
	var dialog: DialogBox = GameManager.dialog_box
	is_talking = true
	dialog.set_speaker(self)
	dialog.set_dialog_text("Vielen Dank für deinen Einkauf!\nKomme bald wieder!")
	dialog.show_dialog()
