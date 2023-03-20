extends Area2D

func _ready():
	self.connect("body_entered", finish_quest)
	
func finish_quest(body):
	if body.name != 'Player' or QuestManager.current_quest == null:
		return
	var quest = QuestManager.current_quest
	if quest.title == "Bat1":
		if quest.state == Quest.QS.ACTIVE:
			quest.add_item()
		elif quest.state == Quest.QS.FINSIH:
			quest.complete()
