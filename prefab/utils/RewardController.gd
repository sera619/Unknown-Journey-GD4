extends Node2D
class_name RewardController

@export_category("Reward Settings")
@export_enum("5%",
"10%", 
"15%", 
"20%",
"25%",
"30%",
"35%",
"40%",
"45%",
"50%",
"55%",
"60%",
"65%",
"70%",
"75%",
"80%",
"85%",
"90%",
"95%",
"100%"
) var reward_chance: int
@export var reward_gold: int
@export var reward_scenes: Array[PackedScene]
@export var quest_reward_scenes: Array[PackedScene]


func get_reward():
	if not _check_can_get_reward():
		return
	var s = GameManager.player.stats
	if s.level >= 2:
		reward_scenes[2] = null
	if not QuestManager.is_quest_complete("Bombig"):
		reward_scenes[3] = null
	var r = randi_range(0, reward_scenes.size() - 1)
	var reward = reward_scenes[r].instantiate()
	if reward.name == "CoinDrop":
		reward.amount = reward_gold
	GameManager.current_world.game_map.add_child(reward)
	reward.global_position = self.global_position

func _check_can_get_reward() -> bool:
	var chance_to_drop = randf_range(0, 100)
	match reward_chance:
		0:
			if chance_to_drop <= 5:
				return true
			else:
				return false
		1: 
			if chance_to_drop <= 10:
				return true
			else:
				return false
		2:
			if chance_to_drop <= 15:
				return true
			else:
				return false
		3:
			if chance_to_drop <= 20:
				return true
			else:
				return false
		4:
			if chance_to_drop <= 25:
				return true
			else:
				return false
		5:
			if chance_to_drop <= 35:
				return true
			else:
				return false
		6:
			if chance_to_drop <= 40:
				return true
			else:
				return false
		7:
			if chance_to_drop <= 45:
				return true
			else:
				return false
		8:
			if chance_to_drop <= 50:
				return true
			else:
				return false
		9:
			if chance_to_drop <= 55:
				return true
			else:
				return false
		10:
			if chance_to_drop <= 60:
				return true
			else:
				return false
		11:
			if chance_to_drop <= 65:
				return true
			else:
				return false
		12:
			if chance_to_drop <= 70:
				return true
			else:
				return false
		13:
			if chance_to_drop <= 75:
				return true
			else:
				return false
		14:
			if chance_to_drop <= 80:
				return true
			else:
				return false
		15:
			if chance_to_drop <= 85:
				return true
			else:
				return false
		16:
			if chance_to_drop <= 90:
				return true
			else:
				return false
		17:
			if chance_to_drop <= 95:
				return true
			else:
				return false
		18:
			return true
	return false
