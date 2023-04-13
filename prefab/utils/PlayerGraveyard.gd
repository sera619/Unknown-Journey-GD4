extends Node2D

@onready var respawn_spot = $RespawnSpot



func interact():
	GameManager.interface.notice_box.show_common_info_notice("Hier ruht der Spieler\n\n%s\n\nLetzter Tod: %s Uhr am %s" % [GameManager.selected_playername, GameManager.player.stats.player_last_death['time'], GameManager.player.stats.player_last_death['date']])

func get_respawn_pos() -> Vector2:
	return respawn_spot.global_position
