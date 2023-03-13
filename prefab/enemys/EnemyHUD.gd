extends Control
class_name EnemyHUD

@export var enemy_stats_path: NodePath

@onready var healthbar: TextureProgressBar = $Healthbar

var stats: EnemyStats = null

func _ready():
	if enemy_stats_path:
		stats = get_node(enemy_stats_path)
	if stats:
		stats.connect("enemy_health_changed", update_health)
		stats.connect("enemy_maxhealth_changed", update_max_health)
		update_health(stats.health)
		update_max_health(stats.max_health)


func update_health(new_health):
	healthbar.value = new_health

func update_max_health(new_max_health):
	healthbar.max_value = new_max_health
