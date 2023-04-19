extends Control
class_name EnemyHUD

@export var enemy_stats_path: NodePath

@onready var healthbar: TextureProgressBar = $Healthbar
@onready var damage_display: RichTextLabel = $DamageDisplay
var stats: EnemyStats = null

func _ready():
	if enemy_stats_path:
		stats = get_node(enemy_stats_path)
	if stats:
		damage_display.text = ""
		damage_display.visible = false
		stats.connect("enemy_health_changed", update_health)
		stats.connect("enemy_maxhealth_changed", update_max_health)
		if get_parent().has_signal("enemy_take_damage"):
			get_parent().connect("enemy_take_damage", show_damage)
		if get_parent().has_signal("enemy_healed"):
			get_parent().connect("enemy_healed", show_heal)
		update_health(stats.health)
		update_max_health(stats.max_health)

func show_heal(healvalue):
	damage_display.text = "[center][wave amp=40 freq=10]\n[color=green]+%s[/color][/wave][/center]" % healvalue
	damage_display.visible = true
	await get_tree().create_timer(1).timeout
	damage_display.text = ""
	damage_display.visible = false


func show_damage(damagevalue):
	damage_display.text = "[center][wave amp=40 freq=10][color=red]\n-%s[/color][/wave][/center]" % damagevalue
	damage_display.visible = true
	await get_tree().create_timer(1).timeout
	damage_display.text = ""
	damage_display.visible = false

func update_health(new_health):
	healthbar.value = new_health

func update_max_health(new_max_health):
	healthbar.max_value = new_max_health
