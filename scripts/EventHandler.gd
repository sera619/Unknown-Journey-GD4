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

signal player_get_healthpot(value)
signal player_get_energiepot(value)

signal game_load_game
