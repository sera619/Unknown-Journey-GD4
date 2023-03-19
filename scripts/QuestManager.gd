extends Node

@onready var available_quest = $Available
@onready var active_quest = $Active
@onready var completed_quest = $Active
@onready var delivered_quest = $Delivered



func find_available(reference: Quest):
	return available_quest.find(reference)

func get_available_quests() -> Array:
	return available_quest.get_quests()

func is_available(reference: Quest) -> bool:
	return available_quest.find(reference) != null

func start(reference: Quest):
	var quest: Quest = available_quest.find(reference)
	quest.connect("completed", _on_quest_completed)
	available_quest.remove_child(quest)
	active_quest.add_child(quest)
	quest._start()

func _on_quest_completed(quest: Quest):
	active_quest.remove_child(quest)
	completed_quest.add_child(quest)

func deliver(quest: Quest):
	"""
	Marking quest as complete, reward player,
	remove from completed quests
	"""
	quest._deliver()
