extends Control
class_name DevConsole

# PASS
@onready var pass_view: VBoxContainer = $BG/MarginContainer/PassView
@onready var main_panel: VBoxContainer = $BG/MarginContainer/MainPanel
@onready var passinput: LineEdit = $BG/MarginContainer/PassView/PassIn
@onready var pass_header: Label = $BG/MarginContainer/PassView/Label
const normal_text = "Enter the password!"
const error_text = "Your are not a developer of the game!"
const GAMEKEY = "hacker"
const ECOLOR = Color(0.97647058963776, 0, 0)
const NORMCOLOR = Color(0.16470588743687, 0.99215686321259, 1)

# CONSOLE
@onready var lvlin = $BG/MarginContainer/MainPanel/Panel/RV/lvlin
@onready var hpin = $BG/MarginContainer/MainPanel/Panel/RV/hpin
@onready var mhpin = $BG/MarginContainer/MainPanel/Panel/RV/mhpin
@onready var expin = $BG/MarginContainer/MainPanel/Panel/RV/expin
@onready var hin = $BG/MarginContainer/MainPanel/Panel/RV/hin
@onready var ein = $BG/MarginContainer/MainPanel/Panel/RV/ein
@onready var dmgin = $BG/MarginContainer/MainPanel/Panel/RV/dmgin
@onready var mdmgin = $BG/MarginContainer/MainPanel/Panel/RV/mdmgin
@onready var goldin = $BG/MarginContainer/MainPanel/Panel/RV/goldin
@onready var infolabel = $BG/MarginContainer/MainPanel/InfoLabel

var ps: Stats = null

func _ready():
	ps = GameManager.player.stats
	pass_header.add_theme_color_override("font_color", NORMCOLOR)
	show_passpanel()

func _input(event):
	if event.is_action_released("devconsole"):
		self.queue_free()
		if GameManager.interface.dev_console:
			GameManager.interface.set_deferred("dev_console", false)
	if event.is_action_pressed("ui_accept") and pass_view.visible:
		_check_key(String(passinput.text))

func _check_key(key: String):
	passinput.text = ""
	if not key == GAMEKEY:
		pass_header.add_theme_color_override("font_color", ECOLOR)
		pass_header.text = error_text
	else:
		pass_header.add_theme_color_override("font_color", NORMCOLOR)
		pass_header.text = normal_text
		show_mainpanel()

func show_mainpanel():
	passinput.text = ""
	self.size.y = 272
	main_panel.visible = true
	pass_view.visible = false

func show_passpanel():
	self.size.y = 133
	main_panel.visible = false
	pass_view.visible = true
	passinput.grab_focus()

# PASS
func _on_pass_btn_button_up():
	_check_key(String(passinput.text))

func _on_pass_back_btn_button_up():
	if GameManager.interface.dev_console:
		GameManager.interface.dev_console = false
	self.queue_free()

# CONSOLE
func _on_level_btn_button_up():
	if ps:
		ps.set_level(ps.level +int(lvlin.text))
#		print("[DEV] Console: Add %s + Level to player!" % lvlin.text)
		infolabel.text = "Add %s + Level" % lvlin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_add_hp_btn_button_up():
	if ps:
		ps.set_health(ps.health + int(hpin.text))
##		print("[DEV] Console: Add %s + Health to player!" % hpin.text)
		infolabel.text = "Add %s + Health" % hpin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_add_xp_button_up():
	if ps:
		GameManager.player.stats.set_exp(ps.experience + int(expin.text))
#		print("[DEV] Console: Add %s + EXP to player!" % expin.text)
		infolabel.text = "Add %s + EXP" % expin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_add_h_pot_btn_button_up():
	if ps:
		InventoryManager.add_item("Heiltrank", int(hin.text))
#		print("[DEV] Console: Add %s + HP pot to player!" % hin.text)
		infolabel.text = "Add %s + Health Pot" % hin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_add_e_pot_btn_button_up():
	if ps:
		InventoryManager.add_item("Energietrank", int(ein.text))
		infolabel.text = "Add %s + Energie Pot" % ein.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_add_dmg_btn_button_up():
	if ps:
		ps.set_damage(ps.damage + int(dmgin.text))
		infolabel.text = "Add %s + Damage" % dmgin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_add_m_dmg_btn_button_up():
	if ps:
		ps.set_max_damage(ps.MAX_DAMAGE + int(mdmgin.text))
		infolabel.text = "Add %s + Max Damage" % mdmgin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_spawn_btn_button_up():
	if ps:
		EventHandler.emit_signal("spawn_enemys")
		infolabel.text = "Respawn Enemys."
#		print("[DEV] Console: Respawn enemys!")
	else:
		print("[DEV] No stats currently loaded!")

func _on_char_btn_button_up():
	if GameManager.interface.charpanel.visible:
		$BG/MarginContainer/MainPanel/H/CharBtn.text = "Show Chari"
		GameManager.interface.charpanel.hide_charpanel()
	else:
		$BG/MarginContainer/MainPanel/H/CharBtn.text = "Hide Chari"
		GameManager.interface.charpanel.show_charpanel()

func _on_exit_btn_button_up():
	if GameManager.interface.dev_console:
		GameManager.interface.dev_console = false
	self.queue_free()

func _on_add_mhp_btn_button_up():
	if ps:
		ps.set_max_health(ps.MAX_HEALTH + int(mhpin.text))
		infolabel.text = "Add %s + Max Health" % mhpin.text


# REMOVE
func _on_rlvl_btn_button_up():
	if ps:
		ps.set_level(ps.level - int(lvlin.text))
#		print("[DEV] Console: Remove %s + Level to player!" % lvlin.text)
		infolabel.text = "Remove %s + Level" % lvlin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_r_hp_btn_button_up():
	if ps:
		ps.set_health(ps.health - int(hpin.text))
##		print("[DEV] Console: Remove %s + Health to player!" % hpin.text)
		infolabel.text = "Remove %s + Health" % hpin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_rmhp_btn_button_up():
	if ps:
		ps.set_max_health(ps.MAX_HEALTH - int(mhpin.text))
		infolabel.text = "Remove %s + Max Health" % mhpin.text

func _on_remove_exp_button_up():
	if ps:
		GameManager.player.stats.set_exp(ps.experience - int(expin.text))
#		print("[DEV] Console: Add %s + EXP to player!" % expin.text)
		infolabel.text = "Remove %s + EXP" % expin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_rhpot_btn_button_up():
	if ps:
		InventoryManager.remove_item("Heiltrank", int(hin.text))
#		print("[DEV] Console: Add %s + HP pot to player!" % hin.text)
		infolabel.text = "Remove %s + Health Pot" % hin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_repot_btn_button_up():
	if ps:
		InventoryManager.remove_item("Energietrank", int(ein.text))
		infolabel.text = "Remove %s + Energie Pot" % ein.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_rdmg_btn_button_up():
	if ps:
		ps.set_damage(ps.damage - int(dmgin.text))
		infolabel.text = "Remove %s + Damage" % dmgin.text
	else:
		print("[DEV] No stats currently loaded!")

func _on_rmdmg_btn_button_up():
	if ps:
		ps.set_max_damage(ps.MAX_DAMAGE - int(mdmgin.text))
		infolabel.text = "Remove %s + Max Damage" % mdmgin.text
	else:
		print("[DEV] No stats currently loaded!")


func _on_rm_gold_btn_button_up():
	if ps:
		ps.set_gold(ps.gold - int(goldin.text))
		infolabel.text = "Remove %s Gold" % goldin.text
		
func _on_add_gold_btn_button_up():
	if ps:
		ps.set_gold(ps.gold + int(goldin.text))
		infolabel.text = "Add %s Gold" % goldin.text
