extends Node
class_name Stats

@export_category('Stat Settings')
@export var playername: String
@export var MAX_ENERGIE: int
@export var MAX_HEALTH: int
@export var MAX_DAMAGE: int
@export var gold: int
@export var MAX_GOLD: int
@export var dmg_label_path: NodePath
@export_category('Movement Settings')
@export var MAX_SPEED:int
@export var RUN_SPEED: int
@export var COMBAT_MOVE_SPEED: int
@export var DASH_SPEED: int
@export var PUSH_SPEED:int
@export var ROLL_SPEED:int
@export var ACCELERATION:int
@export var FRICTION:int

@export_category('Skill Settings')
@export var roll_costs:int
@export var DOUBLE_ATTACK_CAP: int
@export var DOUBLE_ATTACK_COST: int
@export var HEAVY_ATTACK_CAP: int
@export var HEAVY_ATTACK_COST: int

@export_category("Cooldowns")
@export var DASH_COOLDOWN: int
@export var MAGIC_SKILL_COOLDOWN: int

@onready var has_sword: bool = false


var health: int = 0
var level: int = 0
var energie: int = 0 
var experience:int = 0
var max_experience:int = 0
var damage: int = 0
var speed: int = 0
var exp_multiplikator:float = 1.2
var parent = null
var dmg_label: RichTextLabel = null
var played_time = 0

var player_last_death = {
	"time": "",
	"date": ""
}

var player_statistic: Dictionary = {
	"max_dmg_taken": 0,
	"max_gold_hold": 0,
	"max_dmg_done": 0,
	"killed_enemys": 0,
	"total_gold": 0,
	"quest_done": 0,
	"died": 0
}


func _record_playtime(delta: float):
	played_time += delta

func _ready():
	EventHandler.connect("player_died", _check_died)
	EventHandler.connect("player_inventory_equip_changed", _change_equip)
	EventHandler.connect("statistic_update_dmg_done", _check_max_dmg_done)
	EventHandler.connect("statistic_update_dmg_taken", _check_max_dmg_taken)
	EventHandler.connect("statistic_update_killed", _check_killed_enemys)
	EventHandler.connect("statistic_update_quests", _check_quests_done)
	if not parent:
		parent = get_parent().name
	if dmg_label_path:
		dmg_label = get_node(dmg_label_path)
		dmg_label.visible = false
	if GameManager.game.new_game:
		set_default_stats()
		GameManager.game.new_game = false
	else: 
		apply_loaded_stats()

func _update_last_death():
	player_last_death['time'] = Time.get_time_string_from_system()
	player_last_death['date'] = Time.get_date_string_from_system()

func _check_died():
	player_statistic['died'] += 1

func _check_quests_done():
	player_statistic['quest_done'] += 1

func _check_max_dmg_done(value):
	if not value >= player_statistic['max_dmg_done']:
		return
	player_statistic['max_dmg_done'] = value

func _check_max_dmg_taken(value):
	if not value >= player_statistic['max_dmg_taken']:
		return
	player_statistic['max_dmg_taken'] = value

func _check_killed_enemys(value):
	player_statistic['killed_enemys'] += value

func _check_max_gold_hold(value):
	if not value >= player_statistic['max_gold_hold']:
		return
	player_statistic['max_gold_hold'] = value


func _change_equip(equip: Item):
	if not equip.item_type == "Equip":
		return
	self.set_max_damage(equip.item_damage)
	self.set_damage(equip.item_damage)


func set_default_stats():
	if GameManager.new_player_name == "":
		playername = "Sera"
	else:
		playername = GameManager.new_player_name
		GameManager.new_player_name = ""
	set_max_gold(2000)
	set_gold(0)
	set_level(1)
	set_max_damage(1)
	set_max_energie(1)
	set_max_health(20)
	set_max_exp(300)
	set_exp(0)
	set_damage(MAX_DAMAGE)
	set_health(MAX_HEALTH, true)
	set_energie(0)
	print("[!] Data: Set default playerstats!")

func set_health(value, loaded=false):
	var old_healt = health
	health = value
	if health >= MAX_HEALTH:
		health = MAX_HEALTH
	EventHandler.emit_signal("player_health_changed", health)
	if loaded == false:
		if old_healt > health:
			dmg_label.add_theme_color_override("default_color", Color(0.7843137383461, 0.12156862765551, 0.03529411926866))
			show_dmg_display("[wave amp=40 freq=10]\n-%s[/wave]" % int(old_healt - health))
		elif old_healt < health:
			dmg_label.add_theme_color_override("default_color", Color(0.32941177487373, 0.7843137383461, 0.15294118225574))
			show_dmg_display("[wave amp=40 freq=10]\n+%s[/wave]" % int(health - old_healt))


func heal_player(value):
	if health + value > MAX_HEALTH:
		health = MAX_HEALTH
	else:
		health += value
	EventHandler.emit_signal("player_health_changed", health)
	dmg_label.add_theme_color_override("default_color", Color(0.32941177487373, 0.7843137383461, 0.15294118225574))
	dmg_label.text = "[wave amp=40 freq=10]\n+%s[/wave]" % value
	dmg_label.visible = true
	await get_tree().create_timer(1.4).timeout
	dmg_label.text = ""
	dmg_label.visible = false

func show_dmg_display(dmgvalue: String):
	dmg_label.text = dmgvalue
	dmg_label.visible = true
	await get_tree().create_timer(1.4).timeout
	dmg_label.text = ""
	dmg_label.visible = false
	
func set_max_health(value):
	MAX_HEALTH = value
	EventHandler.emit_signal("player_maxhealth_changed", MAX_HEALTH)

func set_speed(value):
	speed = value
	EventHandler.emit_signal("player_speed_changed", speed)

func set_damage(value):
	damage = value
	EventHandler.emit_signal("player_damage_changed", damage)

func set_max_damage(value):
	MAX_DAMAGE = value
	EventHandler.emit_signal("player_maxdamage_changed", MAX_DAMAGE)

func set_max_exp(value):
	max_experience = value
	EventHandler.emit_signal("player_maxexp_changed", max_experience)

func set_exp(value):
	experience = value
	if experience >= max_experience:
		var rest = experience - max_experience
		level_up(rest)
	EventHandler.emit_signal("player_exp_changed", experience)
	
func set_energie(value):
	energie = value
	if energie > MAX_ENERGIE:
		energie = MAX_ENERGIE
	EventHandler.emit_signal("player_energie_changed", energie)

func set_max_energie(value):
	MAX_ENERGIE = value
	EventHandler.emit_signal("player_maxenergie_changed", MAX_ENERGIE)

func set_level(value):
	level = value
	EventHandler.emit_signal("player_level_changed", level)

func set_gold(value):
	player_statistic['total_gold'] += (value - gold)
	gold = value
	_check_max_gold_hold(gold)
	if gold > MAX_GOLD:
		gold = MAX_GOLD
	EventHandler.emit_signal("player_gold_changed", gold)

func set_max_gold(value):
	MAX_GOLD = value
	EventHandler.emit_signal("player_maxgold_changed", MAX_GOLD)

func level_up(rest):
	var new_max_exp = max_experience * exp_multiplikator
	var new_exp = rest
	set_max_exp(new_max_exp)
	set_level(level + 1)
	set_health(MAX_HEALTH)
	set_exp(new_exp)

	if level == 2 or level == 4 or level == 6 or level == 8 or level == 10:
		set_max_health(MAX_HEALTH + 1)
		set_health(MAX_HEALTH)
		set_max_energie(MAX_ENERGIE +1)
		set_energie(0)
	EventHandler.emit_signal("player_level_up")

func add_seen_npc(npcname:String):
	if not npcname in GameManager.seen_npcs: 
		GameManager.seen_npcs.append(npcname)


func apply_loaded_stats():
	var data = D._load_profile_char_data(GameManager.selected_playername)
	if data:
		playername = data['playername']
		MAX_HEALTH = data['max_health']
		has_sword = data['has_sword']
		if has_sword:
			GameManager.interface.actionbar.attack_btn.visible = true
		else:
			GameManager.interface.actionbar.attack_btn.visible = false
		MAX_ENERGIE = data['max_energie']
		experience = data['experience']
		max_experience = data['max_exp']
		level = data['level']
		gold = data['gold']
		player_statistic = data['statistic']
		if data.has('last_death'):
			player_last_death = data['last_death']
		GameManager.seen_npcs.clear()
		for n in data['seen_npcs']:
			GameManager.seen_npcs.append(n)
		if data['played_time'] != null:
			self.played_time = data['played_time']
		print("[!] %s: Set health to %s !" % [parent, MAX_HEALTH])
		set_max_health(MAX_HEALTH)
		set_health(MAX_HEALTH, true)
		set_level(level)
		set_max_exp(max_experience)
		set_exp(experience)
		set_gold(gold)
		set_max_damage(data['max_damage'])
		set_damage(MAX_DAMAGE)
		set_speed(MAX_SPEED)
		set_max_energie(MAX_ENERGIE)
		set_energie(0)

func save():
	var save_dict = {
		"playername": playername,
		"cur_world":GameManager.current_world.world_name,
		"pos_x": get_parent().global_position.x,
		"pos_y": get_parent().global_position.y,
		"cur_health": self.health,
		"max_health": self.MAX_HEALTH,
		"max_energie": self.MAX_ENERGIE,
		"max_damage": self.MAX_DAMAGE,
		"has_sword": self.has_sword,
		"max_exp": self.max_experience,
		"experience": self.experience,
		"level": self.level,
		"seen_npcs": GameManager.seen_npcs,
		"gold": self.gold,
		"played_time": self.played_time,
		"statistic": self.player_statistic,
		"last_death": self.player_last_death
	}
	return save_dict
