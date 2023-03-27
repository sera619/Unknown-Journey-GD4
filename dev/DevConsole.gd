extends Control
class_name DevConsole

# PASS
@onready var pass_view: VBoxContainer = $BG/MarginContainer/PassView
@onready var main_panel: HBoxContainer = $BG/MarginContainer/Panel
@onready var passinput: LineEdit = $BG/MarginContainer/PassView/PassIn
@onready var pass_header: Label = $BG/MarginContainer/PassView/Label
const normal_text = "Enter the password!"
const error_text = "Your are not a developer of the game!"
const GAMEKEY = "hacker"
const ECOLOR = Color(0.97647058963776, 0, 0)
const NORMCOLOR = Color(0.16470588743687, 0.99215686321259, 1)

# CONSOLE
@onready var lvlin = $BG/MarginContainer/Panel/RV/lvlin
@onready var hpin = $BG/MarginContainer/Panel/RV/hpin
@onready var expin = $BG/MarginContainer/Panel/RV/expin
@onready var hin = $BG/MarginContainer/Panel/RV/hin
@onready var ein = $BG/MarginContainer/Panel/RV/ein
@onready var dmgin =$BG/MarginContainer/Panel/RV/dmgin

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
	self.size.y = 128
	main_panel.visible = true
	pass_view.visible = false

func show_passpanel():
	self.size.y = 105
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
		print("[DEV] Console: Add %s + Level to player!" % lvlin.text)
	else:
		print("[DEV] No stats currently loaded!")

func _on_add_hp_btn_button_up():
	if ps:
		ps.set_health(ps.health + int(hpin.text))
		print("[DEV] Console: Add %s + Health to player!" % hpin.text)
	else:
		print("[DEV] No stats currently loaded!")

func _on_add_xp_button_up():
	if ps:
		GameManager.player.stats.set_exp(ps.experience + int(expin.text))
		print("[DEV] Console: Add %s + EXP to player!" % expin.text)
	else:
		print("[DEV] No stats currently loaded!")

func _on_add_h_pot_btn_button_up():
	if ps:
		ps.player_inventory['Healthpot'] += int(hin.text)
		EventHandler.emit_signal("player_get_healthpot", ps.player_inventory['Healthpot'])
		print("[DEV] Console: Add %s + HP pot to player!" % hin.text)
	else:
		print("[DEV] No stats currently loaded!")

func _on_add_e_pot_btn_button_up():
	if ps:
		ps.player_inventory['Energiepot'] += int(ein.text)
		EventHandler.emit_signal("player_get_energiepot", ps.player_inventory['Energiepot'])
		print("[DEV] Console: Add %s + E pot to player!" % ein.text)
	else:
		print("[DEV] No stats currently loaded!")

func _on_spawn_btn_button_up():
	if ps:
		EventHandler.emit_signal("spawn_enemys")
		print("[DEV] Console: Respawn enemys!" % expin.text)
	else:
		print("[DEV] No stats currently loaded!")
