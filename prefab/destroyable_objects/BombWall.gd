extends Area2D


@export_enum("No Way", "Way") var wall_type: int
@export var effect_scene: PackedScene
@export var sound_scene: PackedScene
@export var way_sprite: Texture
@export var noway_sprite: Texture
@onready var sprite: Sprite2D = $Sprite2D


func _ready():
	self.connect("area_entered", _create_effect)
	match wall_type:
		0:
			sprite.texture = noway_sprite
		1:
			sprite.texture = way_sprite

func interact():
	GameManager.interface.notice_box.show_common_info_notice("Die Felsenwand\n\nscheint dort etwas\n\ninstabil zu sein.")


func _create_effect(area):
	if not area.is_in_group("playerSword"):
		return
	if not sound_scene and not effect_scene:
		_kill()
	if effect_scene:
		var effect = effect_scene.instantiate()
		effect.connect("effect_finished", _kill)
		self.add_child(effect)
		effect.global_position = self.global_position
	if sound_scene:
		var sound = sound_scene.instantiate()
		get_tree().current_scene.add_child(sound)
	
func _kill():
	call_deferred("queue_free")
