extends Node2D
class_name EnemyDummy

@export var hit_scene: PackedScene
@export var hit_sound_scene: PackedScene

@onready var enemy_stats: EnemyStats = $EnemyStats
@onready var hitbox: Area2D = $Hitbox
@onready var value_display: ValueDisplay = $ValueDisplay
@onready var enemy_hud: EnemyHUD = $EnemyHUD
@onready var body_sprite: Sprite2D = $Sprite2D


func _ready():
	hitbox.connect("area_entered", _on_hitbox_entered)


func _on_hitbox_entered(area):
	if not area.is_in_group("playerSword"):
		return
	if GameManager.player.stats.has_sword and area.attack_type == 0:
		GameManager.player.stats.set_energie(GameManager.player.stats.energie + 1)
	value_display._show_dmg_value(area.damage)
	_create_hit_effect()
	enemy_stats.take_damage(area.damage)

func _create_hit_effect():
	var effect = hit_scene.instantiate()
	self.add_child(effect)
	effect.global_position.y = self.global_position.y + body_sprite.offset.y
	var sound = hit_sound_scene.instantiate()
	self.add_child(sound) 
	if enemy_stats.health == 0:
		enemy_stats.heal_enemy()
		value_display._show_heal_value(enemy_stats.max_health)
