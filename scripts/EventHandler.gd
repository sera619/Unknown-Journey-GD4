extends Node

signal questmob_killed
signal questitem_found
signal quest_complete(quest)

signal puzzle_activated(id)
signal puzzle_deactivated(id)
signal puzzle_solved

signal transition_black
signal start_transition

signal player_health_changed(health)
signal player_maxhealth_changed(max_health)
signal player_speed_changed(speed)
signal player_damage_changed(damage)
signal player_maxdamage_changed(max_damage)
signal player_exp_changed(exp)
signal player_maxexp_changed(max_exp)
signal player_energie_changed(energie)
signal player_maxenergie_changed(max_energie)
signal player_level_changed(level)
signal player_level_up
signal player_died
signal player_sleep
signal player_dot_start(dot_count, dot_element)
signal player_get_healthpot(value)
signal player_get_energiepot(value)
signal player_gold_changed(value)
signal player_maxgold_changed(value)
signal player_set_interact(mode)

signal statistic_update_gold(amount)
signal statistic_update_killed(amount)
signal statistic_update_dmg_done(amount)
signal statistic_update_dmg_taken(amount)
signal statistic_update_quests
signal player_inventory_item_changed(item)
signal player_inventory_equip_changed(equip)

signal actionbar_disable
signal actionbar_enable


signal show_world_shadow
signal game_load_game

signal start_rain
signal stop_rain

signal spawn_enemys

signal version_outdated


