extends Node
class_name DebuffHandler

@export_category("Debuff Scenes")
@export var poison_debuff_scene: PackedScene
@export var fire_debuff_scene: PackedScene
@export var ice_debuff_scene: PackedScene
@export var lightning_debuff_scene: PackedScene


func get_debuff_effect(element):
	var effect
	match element:
		SkillManager.ELEMENT.POISON:
			effect = poison_debuff_scene.instantiate()
		SkillManager.ELEMENT.LIGHTNING:
			effect = lightning_debuff_scene.instantiate()
		SkillManager.ELEMENT.FIRE:
			effect = fire_debuff_scene.instantiate()
		SkillManager.ELEMENT.ICE:
			effect = ice_debuff_scene.instantiate()
	#print("[!] DebuffHandler: Add debuff Scene to %s" % get_parent().name)
	self.add_child(effect)
