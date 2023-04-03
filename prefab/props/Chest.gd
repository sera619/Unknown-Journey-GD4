extends Node2D
class_name Chest

@export var chest_id: int = 1
@export_enum("Normal", "Special") var chest_type: int
@export var reward_list: Array[PackedScene]
@export var open_sound_scene: PackedScene
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var player_detector: PlayerDetector = $PlayerDetector

var is_open: bool = false
var reward_given: bool = false

func _ready():
	anim_player.connect("animation_finished", _on_animation_finished)

func _open_chest():
	if is_open:
		return
	else:
		var sound = open_sound_scene.instantiate()
		self.add_child(sound)
		#await get_tree().create_timer(0.4).timeout
		is_open = true
		anim_player.play("open")

func _reward_player():
	if reward_given:
		return
	else:
		reward_given = true
		var reward_size = reward_list.size()
		var item = reward_list[ randi_range(0, reward_size)-1].instantiate()
		InventoryManager.add_item(item.item_name, 1)

func _on_animation_finished(anim_name):
	if anim_name == "open":
		_reward_player()

func _process(delta):
	if Input.is_action_just_released("interact") and player_detector.can_see_player():
		_open_chest()
