extends Node2D
class_name ItemDrop

@export_category('Item Settings')
@export var item_name: String
@export var item_image: Texture2D
@export var shadow_image: Texture2D
@export_enum('Normal', 'Quest') var item_type: int
@export var quest_id: int
@export var amount: int
@export var despawn_time: int
@export_category("Sound Settings")
@export var potiondrop_sound_scene: PackedScene

@onready var pickup_zone: Area2D = $Area2D 
@onready var shadow_sprite: Sprite2D = $Shadow
@onready var body_sprite: Sprite2D = $Body
@onready var animplayer: AnimationPlayer = $AnimationPlayer
@onready var coll_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var timer: Timer = $Timer

func _ready():
	body_sprite.texture = item_image
	shadow_sprite.texture = shadow_image
	pickup_zone.connect("area_entered", pickup)
	animplayer.play("loop")
	if item_type == 0:
		if potiondrop_sound_scene != null:
			var sound = potiondrop_sound_scene.instantiate()
			get_tree().current_scene.add_child(sound)
		body_sprite.scale = Vector2(0.35, 0.35)
		coll_shape.shape.height = 10
		coll_shape.shape.radius = 3
		coll_shape.position.y = 0
		#body_sprite.scale.y = 0.25
		#body_sprite.scale.x = 0.25 
		if despawn_time != 0:
			timer.wait_time = despawn_time
		else:
			despawn_time = 10
		timer.wait_time = despawn_time
		timer.start()



func pickup(area):
	if not area.is_in_group("playerPickupzone"):
		return
	if item_type == 1:
		GameManager.quest_system._add_quest_item("Das Schwert")
	elif item_type == 0:
		if item_name:
			GameManager.player.stats.get_item(item_name, amount)
			GameManager.info_box.set_info_text("Du hast\n\n[color=red]%sx %s[/color]\n\nerhalten!" % [amount, item_name])
	self.call_deferred("queue_free")



func _on_timer_timeout():
	self.call_deferred("queue_free")
	print("[!] ItemDrop: Item \"%s\" is despawned after %s seconds!" % [item_name, despawn_time])
