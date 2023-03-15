extends Node2D
class_name ItemDrop

@export_category('Item Settings')
@export var item_name: String
@export var item_image: Texture2D
@export var shadow_image: Texture2D
@export_enum('Normal', 'Quest') var item_type: int
@export var quest_id: int
@export var amount: int


@onready var pickup_zone: Area2D = $Area2D 
@onready var shadow_sprite: Sprite2D = $Shadow
@onready var body_sprite: Sprite2D = $Body
@onready var animplayer: AnimationPlayer = $AnimationPlayer

func _ready():
	body_sprite.texture = item_image
	shadow_sprite.texture = shadow_image
	pickup_zone.connect("area_entered", pickup)
	animplayer.play("loop")


func pickup(area):
	if not area.is_in_group("playerPickupzone"):
		return
	if item_type == 1:
		if not QuestManager.current_quest:
			return
		var required_quest_id = QuestManager.current_quest.quest_id
		if required_quest_id == self.quest_id:
			QuestManager.current_quest.add_quest_items()
	elif item_type == 0:
		match item_name:
			"Health Potion":
				GameManager.player.stats.get_item(item_name, amount)
				GameManager.info_box.set_info_text("Du hast\n%sx %s\nerhalten!" % [amount, "Heiltrank"])
	self.call_deferred("queue_free")

