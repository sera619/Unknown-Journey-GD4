extends Node2D
class_name Chest

@export var chest_id: int = 1
@export_enum("Wood", "Red") var chest_type: int
@export var reward_list: Array[PackedScene]
@export var open_sound_scene: PackedScene
@onready var player_detector: PlayerDetector = $PlayerDetector
@onready var body_sprite: AnimatedSprite2D = $Body
@onready var icon: Sprite2D = $Icon
@onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D
@onready var detector_collision: CollisionShape2D = $PlayerDetector/CollisionShape2D
@onready var shadow: Sprite2D = $Shadow

var is_open: bool = false
var reward_given: bool = false


func _ready():
	match chest_type:
		0:
			body_sprite.animation = "wood"
			body_sprite.offset.y = -4
			body_sprite.frame = 0
			collision.shape.size = Vector2(14.443, 7.159)
			detector_collision.shape.radius = 13.5
			shadow.scale = Vector2(0.67, 0.281)
			shadow.position = Vector2(0, 0)
		1:
			body_sprite.animation = "red"
			body_sprite.offset.y = -8
			body_sprite.frame = 0
			collision.shape.size = Vector2(31.865, 13.453)
			detector_collision.shape.radius = 23.1 
			shadow.scale = Vector2(1.287, 0.603)
			shadow.position = Vector2(0, 1.197)
	body_sprite.connect("animation_finished", _on_animation_finished)
	call_deferred("_check_unique")

func _check_unique():
	await get_tree().create_timer(0.5).timeout
	var unique_data: Dictionary = D.unique_open_data
	if unique_data.has(str(GameManager.current_world.world_name)):
		for i in unique_data[str(GameManager.current_world.world_name)]:
			if i == chest_id:
				is_open = true
				reward_given = true
				match chest_type:
					0:
						body_sprite.frame = 6
					1:
						body_sprite.frame = 6 
				break
			else:
				continue
	else:
		D.unique_open_data[str(GameManager.current_world.world_name)] = []
		print("[Data]: New Unique-List created for %s" % GameManager.current_world.world_name)

func _open_chest():
	if is_open:
		return
	else:
		var sound = open_sound_scene.instantiate()
		self.add_child(sound)
		#await get_tree().create_timer(0.4).timeout
		D.unique_open_data[str(GameManager.current_world.world_name)].append(chest_id)
		is_open = true
		match chest_type:
			0:
				body_sprite.play("wood")
			1:
				body_sprite.play("red")

func _reward_player():
	if reward_given:
		return
	else:
		reward_given = true
		var reward_size = reward_list.size()
		var item = reward_list[ randi_range(0, reward_size)-1].instantiate()
		InventoryManager.add_item(item.item_name, randi_range(1, 4))

func _on_animation_finished():
	_reward_player()

func _process(_delta):
	if player_detector.can_see_player() and not is_open:
		icon.show()
		if Input.is_action_just_released("interact"):
			_open_chest()
	if is_open and icon.visible:
		icon.hide()
