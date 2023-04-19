extends Node2D
class_name WeaponEffect

@export var effect_damage: int
@export_enum("None", "Ice", "Fire", "Lightning", "Poison") var element_type: int

@onready var lightning_impact_sound: PackedScene = preload("res://prefab/audio/LightningImpactSound.tscn")
@onready var fire_impact_sound: PackedScene = preload("res://prefab/audio/FireImpactSound.tscn")
@onready var ice_impact_sound: PackedScene = preload("res://prefab/audio/IceImpact.tscn")
@onready var hitbox = $Hitbox
@onready var collider = $Hitbox/CollisionShape2D
@onready var body = $Body
@onready var effect_element: SkillManager.ELEMENT = SkillManager.ELEMENT.NONE

func _ready():
	hitbox.damage = effect_damage
	body.connect("animation_finished", _kill)
	#body.connect("frame_changed", _enable_collider)
	_set_element()
	match effect_element:
		SkillManager.ELEMENT.NONE:
			pass
		SkillManager.ELEMENT.ICE:
			body.offset = Vector2(0, -128)
			body.scale = Vector2(0.25, 0.25)
			body.play("ice_animate")
			var sound = ice_impact_sound.instantiate()
			self.add_child(sound)
		SkillManager.ELEMENT.FIRE:
			body.offset = Vector2(0, -38)
			body.scale =Vector2(0.85, 0.85)
			body.play("fire_animate")
			var sound = fire_impact_sound.instantiate()
			self.add_child(sound)
		SkillManager.ELEMENT.LIGHTNING:
			body.offset = Vector2(0, -256)
			body.scale = Vector2(0.35, 0.35)
			body.play("lightning_animate")
			var sound = lightning_impact_sound.instantiate()
			self.add_child(sound)
			

func _kill():
	self.call_deferred("queue_free")

func _set_element():
	match element_type:
		0:
			effect_element = SkillManager.ELEMENT.NONE
		1:
			effect_element = SkillManager.ELEMENT.ICE
		2:
			effect_element = SkillManager.ELEMENT.FIRE
		3:
			effect_element = SkillManager.ELEMENT.LIGHTNING
		4:
			effect_element = SkillManager.ELEMENT.POISON
