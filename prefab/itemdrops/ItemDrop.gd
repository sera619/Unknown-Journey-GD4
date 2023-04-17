extends Node2D
class_name ItemDrop
signal interaction_finished()

@export_category('Item Settings')
@export var item_name: String
@export var item_image: Texture2D
@export var shadow_image: Texture2D
@export var particle_material: ParticleProcessMaterial
@export_enum('Normal', 'Consumable', 'Quest', 'Gold', "Equip") var item_type: int
@export var quest_id: int
@export var amount: int
@export var despawn_time: int
@export_category("Sound Settings")
@export var item_drop_sound: PackedScene
@export var quest_pick_sound: PackedScene
@export var interact_sound: PackedScene
@export var collect_coin_sound: PackedScene

@onready var pickup_zone: Area2D = $Area2D 
@onready var shadow_sprite: Sprite2D = $Shadow
@onready var body_sprite: Sprite2D = $Body
@onready var animplayer: AnimationPlayer = $AnimationPlayer
@onready var coll_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var timer: Timer = $Timer
@onready var particles: GPUParticles2D = $Body/ItemDropParticle

func _ready():
	particles.emitting = true
	if particle_material:
		particles.process_material = particle_material
	body_sprite.texture = item_image
	animplayer.connect("animation_finished", _change_animation)
	shadow_sprite.texture = shadow_image
	if item_type == 3:
		body_sprite.hframes = 16
	pickup_zone.connect("area_entered", pickup)
	animplayer.play("drop")
	if item_drop_sound != null:
		var sound = item_drop_sound.instantiate()
		get_tree().current_scene.add_child(sound)
	if item_type == 1:
		body_sprite.scale = Vector2(0.35, 0.35)
		coll_shape.shape.height = 10
		coll_shape.shape.radius = 3
		coll_shape.position.y = 0
		#body_sprite.scale.y = 0.25
		#body_sprite.scale.x = 0.25 
		if despawn_time != 0:
			timer.wait_time = despawn_time
			timer.start()
		
func _change_animation(anim_name):
	if anim_name == "drop":
		animplayer.play("loop")

func pickup(area):
	if not area.is_in_group("playerPickupzone"):
		return
	if item_type == 2:
		if QuestManager.current_quest:
			if QuestManager.current_quest.title == "Das Schwert" and self.item_name == "Schwert":
				var sound = quest_pick_sound.instantiate()
				get_tree().current_scene.add_child(sound)
				QuestManager.current_quest.add_item()
			elif QuestManager.current_quest.title == "Bombig" and self.item_name == "Asche":
				QuestManager.current_quest.add_item()
	elif item_type == 0:
		if item_name:
			if interact_sound:
				var sound = interact_sound.instantiate()
				get_tree().current_scene.add_child(sound)
			GameManager.interface.notice_box.show_item_notice(item_name, amount)
	elif item_type == 1:
		if item_name:
			if interact_sound:
				var sound = interact_sound.instantiate()
				get_tree().current_scene.add_child(sound)
			InventoryManager.add_item(item_name, amount)
	elif item_type == 3:
		if collect_coin_sound:
			var sound = collect_coin_sound.instantiate()
			get_tree().current_scene.add_child(sound)
		GameManager.interface.notice_box.show_item_notice("Gold", amount)
		GameManager.player.stats.set_gold(GameManager.player.stats.gold + amount)
	elif item_type == 4:
		if item_name:
			if interact_sound:
				var sound = interact_sound.instantiate()
				get_tree().current_scene.add_child(sound)
			InventoryManager.add_equip(item_name)
	self.call_deferred("queue_free")



func _on_timer_timeout():
	self.call_deferred("queue_free")
	print("[!] ItemDrop: Item \"%s\" is despawned after %s seconds!" % [item_name, despawn_time])
