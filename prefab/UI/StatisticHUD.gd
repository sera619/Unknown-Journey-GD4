extends Control
class_name StatisticHUD

@onready var head_label: Label =$BG/M/V/HeadBG/Label
@onready var info_label: Label = $BG/M/V/MainBG/M/V/Info
@onready var enemys_label: Label =$BG/M/V/MainBG/M/V/H/KilledEnemys
@onready var max_gold_label: Label =$BG/M/V/MainBG/M/V/H4/MaxGoldHold
@onready var total_gold_label: Label =$BG/M/V/MainBG/M/V/H5/TotalGold
@onready var dmg_done_label: Label =$BG/M/V/MainBG/M/V/H2/DmgDone
@onready var dmg_taken_label: Label = $BG/M/V/MainBG/M/V/H3/DmgTaken
@onready var time_played_label: Label = $BG/M/V/MainBG/M/V/H6/TimePlayed

@onready var exit_btn: TextureButton = $BG/M/V/TextureButton


func _ready():
	self.hide()
	head_label.add_theme_color_override("font_color", GameManager.COLORS.lightgreen_text)
	exit_btn.connect("button_down", hide_statistic)
	dmg_done_label.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	enemys_label.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	total_gold_label.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	max_gold_label.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	dmg_taken_label.add_theme_color_override("font_color", GameManager.COLORS.orange_text)
	time_played_label.add_theme_color_override("font_color", GameManager.COLORS.orange_text)

func show_statistic():
	self.show()
	self._update_statistic()

func hide_statistic():
	self.hide()

func _update_statistic():
	var s = GameManager.player.stats.player_statistic
	info_label.text = "Spielerstatistik für\nden Spieler \"%s\"" % GameManager.selected_playername
	max_gold_label.text = str(s['max_gold_hold'])
	total_gold_label.text = str(s['total_gold'])
	dmg_done_label.text = str(s['max_dmg_done'])
	dmg_taken_label.text = str(s['max_dmg_taken'])
	enemys_label.text = str(s['killed_enemys'])
	time_played_label.text = GameManager.get_played_time_string(GameManager.player.stats.played_time)
