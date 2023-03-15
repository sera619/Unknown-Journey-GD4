extends Node
class_name Stats

signal health_changed
signal energie_changed

@export_category('Stat Settings')
@export var playername: String
@export var MAX_ENERGIE: int
@export var MAX_HEALTH: int
@export var MAX_DAMAGE: int
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
@export var HEAVY_ATTACK_COST: int

@onready var has_sword: bool = true


var health: int = 0
var level: int = 0
var energie: int = 0 
var experience:int = 0
var max_experience:int = 0
var damage: int = 0
var speed: int = 0
var exp_multiplikator:float = 1.2
var parent = null


var player_inventory = {
	"Healthpot": 0,
	"Manapot": 0,
}


func _ready():
	if not parent:
		parent = get_parent().name
	if GameManager.game.loaded_data == null:
		set_default_stats()
	else: 
		apply_loaded_stats()


func get_item(item_name: String, amount: int):
	match item_name:
		"Health Potion":
			player_inventory['Healthpot'] += amount
			EventHandler.emit_signal("player_get_healthpot", player_inventory['Healthpot'])

func set_default_stats():
	playername = "[Admin] Sera"
	set_level(1)
	set_max_damage(2)
	set_max_energie(2)
	set_max_health(4)
	set_max_exp(300)
	set_exp(0)
	set_damage(MAX_DAMAGE)
	set_health(MAX_HEALTH)
	set_energie(0)
	print("[!] Data: Set default playerstats!")

func set_health(value):
	health = value
	if health >= MAX_HEALTH:
		health = MAX_HEALTH
	emit_signal("health_changed")
	EventHandler.emit_signal("player_health_changed", health)

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
	EventHandler.emit_signal("player_energie_changed", energie)

func set_max_energie(value):
	MAX_ENERGIE = value
	EventHandler.emit_signal("player_maxenergie_changed", MAX_ENERGIE)

func set_level(value):
	level = value
	EventHandler.emit_signal("player_level_changed", level)

func level_up(rest):
	set_max_exp(int(max_experience * exp_multiplikator))
	set_exp(rest)
	set_level(level + 1)
	set_max_health(int(MAX_HEALTH * exp_multiplikator))
	set_max_energie(int(MAX_ENERGIE * exp_multiplikator))
	set_health(MAX_HEALTH)
	EventHandler.emit_signal("player_level_up")

func add_seen_npc(npcname:String):
	if not npcname in GameManager.seen_npcs: 
		GameManager.seen_npcs.append(npcname)

func apply_loaded_stats():
	var data = GameManager.load_savegame()
	MAX_HEALTH = data['max_health']
	has_sword = data['has_sword']
	MAX_ENERGIE = data['max_energie']
	experience = data['experience']
	max_experience = data['max_exp']
	level = data['level']
	player_inventory = data['player_inventory']
	GameManager.seen_npcs.clear()
	for n in data['seen_npcs']:
		GameManager.seen_npcs.append(n)
	print("[!] %s: Set health to %s !" % [parent, MAX_HEALTH])
	set_max_health(MAX_HEALTH)
	set_health(MAX_HEALTH)
	set_level(level)
	set_max_exp(max_experience)
	set_exp(experience)
	set_max_damage(data['max_damage'])
	set_damage(MAX_DAMAGE)
	set_speed(MAX_SPEED)
	set_max_energie(MAX_ENERGIE)
	set_energie(0)

func save():
	var quests= []
	var solved_quests = []
	var finished_quest = []
	for i in QuestManager.player_quest_log:
		if i.quest_state == Quest.QS.ACTIVE:
			var quest_infos = [i.quest_name, i.current_quantity]
			quests.append(quest_infos)
		if i.quest_state == Quest.QS.COMPLETE:
			solved_quests.append(i.quest_name)
		if i.quest_state == Quest.QS.FINISHED:
			finished_quest.append(i.quest_name)
	var cq
	if QuestManager.current_quest:
		cq = QuestManager.current_quest.quest_name
	else:
		cq = ""
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
		"current_quest": cq,
		"quest_log_active": quests,
		"quest_log_complete": solved_quests,
		"quest_log_finished": finished_quest,
		"seen_npcs": GameManager.seen_npcs,
		"player_inventory": player_inventory
	}
	return save_dict
