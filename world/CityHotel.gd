extends WorldBase


@onready var prof_spawn = $Map/GameObjects/NPC/ProfSpawn
@onready var questchecker = $Map/Questchecker
@export var prof_scene: PackedScene

func _ready():
	_on_ready()
	get_tree().call_group("world_light", "_light_on")
	if not QuestManager.is_quest_availble("Das Labor"):
		questchecker.queue_free()
	questchecker.connect("body_entered", _spawn_prof)

func _spawn_prof(body):
	if !body.name == "Player":
		return
	if _check_prof_quest():
		var prof = prof_scene.instantiate()
		prof.global_position = prof_spawn.global_position
		npc_container.call_deferred("add_child",prof)

func _check_prof_quest() -> bool:
	if QuestManager.is_quest_complete("Befreiung"):
		return true
	return false
