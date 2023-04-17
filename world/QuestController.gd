extends Node2D
class_name QuestController


@export var quest_name: String
@export var required_amount: int
@export var object_ids: Array[int]

var active_objects: Array = []

func _ready():
	for o in get_children():
		o.connect("puzzle_piece_on", _object_is_active)

func _object_is_active(id):
	if active_objects.has(id):
		return
	active_objects.append(id)
	if _check_condition():
		get_tree().call_group("doors", "unlock_door")
		if QuestManager.current_quest:
			var q = QuestManager.current_quest
			if q.title == "Befreiung":
				q.add_item()

func _check_condition() -> bool:
	if required_amount == active_objects.size():
		return true
	return false
